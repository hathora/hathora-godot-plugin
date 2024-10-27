#TODO: Reset token in case of token error
@tool
extends Node

@export var log_text: RichTextLabel
@onready var sdk = %SDK

const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")

var _profile: Dictionary
var last_created_build_id: String
var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)

func do_upload_and_create_build() -> bool:
	# Get the file size in bytes
	var file = FileAccess.open(HathoraProjectSettings.get_s("path_to_tar_file"), FileAccess.READ)
	if not file:
		print("[HATHORA] Tar file not found")
		return true
	var file_size = file.get_length()
	
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	
	
	var res = await sdk.builds_v3.create(file_size).async()
	if res.is_error():
		print("[HATHORA] Failed to create build: "+ res.as_error().message)
		if res.as_error().error == 401:
			owner.reset_token()
		return true
	
	res = res.get_data()
	var file_content = file.get_buffer(file_size)
	
	var path_absolute = file.get_path_absolute()
	var mb_size = str(get_size_in_mb(file_content))
	print_rich("[HATHORA] Uploading [url=%s]%s[/url] (%sMB)" % [path_absolute.get_base_dir(), path_absolute, mb_size])

	
	#Upload the build
	var err = await upload_to_multipart_url(res.uploadParts, res.maxChunkSize, res.completeUploadPostRequestUrl, file_content)
	
	if err:
		print("[HATHORA] Error uploading the build to multipart URL")
		return true
	
	print("[HATHORA] Upload complete, running build in Hathora, this may take several minutes..")
	
	last_created_build_id = res.buildId

	res = await sdk.builds_v3.run_build(last_created_build_id).async()
	
	if res.is_error():
		print("[HATHORA] Failed to run build: "+ res.as_error().message)
		return true
	
	print("[HATHORA] Created new build with buildId: %s" % [str(last_created_build_id)])
	
	var deployment_config := {
		"requestedCPU" = %DeploymentSettings.requested_cpu,
		"requestedMemoryMB" = %DeploymentSettings.requested_memory * 1024,
		"roomsPerProcess" = %DeploymentSettings.rooms_per_process,
		"transportType" = %DeploymentSettings.transport_type,
		"containerPort" = %DeploymentSettings.container_port,
		"env" = [],
		"buildId" = last_created_build_id,
		"idleTimeoutEnabled" = false
	}
		
	
	if HathoraProjectSettings.get_s("application_id").is_empty():
		print("[HATHORA] Empty appId, cannot create a new deployment")
		return true
	
	# This would automatically update the Deployment Settings, but we do not care because they are remporarily set to read only
	var data : Dictionary = await %LatestDeploymentGetter.get_latest_deployment()

	# The API returns resource arrays, which we need to transform into an array of dictionaries
	
	if "env" in data:
		deployment_config.env = data.env
	if "additionalContainerPorts" in data:
		deployment_config.additionalContainerPorts = data.additionalContainerPorts
	if "idleTimeoutEnabled" in data:
		deployment_config.idleTimeoutEnabled = data.idleTimeoutEnabled
	
	res = await sdk.deployments_v3.create(HathoraProjectSettings.get_s("application_id"), deployment_config).async()
	
	if res.is_error():
		print("[HATHORA] Failed to create deployment: "+ res.as_error().message)
		return true

	print("[HATHORA] Created new deployment with deploymentId: %s" % [str(res.deploymentId)])
	# Wait for 2 seconds otherwise the API does not find the latest deployment
	await get_tree().create_timer(2.0)
	%LatestDeploymentGetter.get_latest_deployment()
	return false

# Function to upload parts
# Helper function to upload file in parts
func upload_to_multipart_url(
	multipart_upload_parts: Array, 
	max_chunk_size: int, 
	complete_upload_post_request_url: String, 
	file: PackedByteArray
) -> bool:
	
	http_request.cancel_request()
	http_request.timeout = 900
	if OS.get_name() != "Web":
		http_request.use_threads = true
	
	var upload_promises = []
	
	for part in multipart_upload_parts:
		var part_number = part["partNumber"]
		var put_request_url = part["putRequestUrl"]
		var start_byte_for_part = (part_number - 1) * max_chunk_size
		var end_byte_for_part = min(part_number * max_chunk_size, file.size())
		var file_chunk = file.slice(start_byte_for_part, end_byte_for_part)

		# Upload each chunk using an HTTPRequest node
		var mb_size = str(get_size_in_mb(file_chunk))
		print("[HATHORA] Uploading part {part_number} ({mb_size}MB) of {total_parts}...".format({"part_number":part_number, "mb_size": mb_size, "total_parts":len(multipart_upload_parts)}))
		var err = http_request.request_raw(put_request_url, PackedStringArray(["Content-Type : application/octet-stream", "Content-Length : "+ str(len(file_chunk))]), HTTPClient.METHOD_PUT, file_chunk)
		if err != OK:
			print("[HATHORA] Build upload HTTP request fail")
			return true
		
		var res = await http_request.request_completed
		if res[1] != 200:
			print("[HATHORA] HTTP error " + str(res[1]))
			var xml : PackedByteArray = res[3]
			print("[HATHORA] HTTP response body: " + xml.get_string_from_utf8())
			return true
		var headers = res[2]
		var etag := ""
		for header in headers:
			if header.begins_with("ETag:"):
				etag = header.split(": ")[1]

		if etag.is_empty():
			print("[HATHORA] ETag not found in response headers for part " + str(part_number))
			return true

		upload_promises.append({ "ETag": etag, "PartNumber": part_number })
		print("[HATHORA] Uploaded part {part_number} of {total_parts}".format({"part_number":part_number, "total_parts":len(multipart_upload_parts)}))
	

	# Now, finalize the upload with a POST request containing the parts' ETags
	var xml_parts = ""
	for part in upload_promises:
		xml_parts += """
		<Part>
			<PartNumber>%s</PartNumber>
			<ETag>%s</ETag>
		</Part>
		""" % [str(part["PartNumber"]), str(part["ETag"])]

	var xml_body = "<CompleteMultipartUpload>%s</CompleteMultipartUpload>" % xml_parts
	var err = http_request.request(complete_upload_post_request_url, PackedStringArray(["Content-Type : application/xml"]), HTTPClient.METHOD_POST, xml_body)
	if err != OK:
		print("[HATHORA] Build upload HTTP request fail")
		return true
	
	var res = await http_request.request_completed
	
	if res[1] != 200:
		print("[HATHORA] Build upload HTTP request fail")
		return true
	
	return false

func get_size_in_mb(chunk: PackedByteArray) -> float:
	var mb_size = float(len(chunk))/1024/1024
	mb_size = snapped(mb_size, 0.01)
	return mb_size

# Otherwise Godot hangs when trying to close while an HTTP request is active
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		http_request.cancel_request()
		get_tree().quit()
