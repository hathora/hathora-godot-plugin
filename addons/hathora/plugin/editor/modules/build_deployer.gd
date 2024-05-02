@tool
extends Node

@export var log_text: RichTextLabel

const BuildV1Api = preload("res://addons/hathora/plugin/apis/BuildV1Api.gd")
const ApiConfig = preload("res://addons/hathora/plugin/core/ApiConfig.gd")
const DeploymentV1Api = preload("res://addons/hathora/plugin/apis/DeploymentV1Api.gd")
const DeploymentConfig = preload("res://addons/hathora/plugin/models/DeploymentConfig.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")

var _profile: Dictionary
var _build_api: BuildV1Api
var _config: ApiConfig
var last_created_build_id: int
	
func do_upload_and_create_build(on_complete: Callable) -> void:
	_config = ApiConfig.new()
	_config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	_build_api = BuildV1Api.new(_config)
	_build_api.create_build(HathoraProjectSettings.get_s("application_id"), _create_build_callback_success.bind(on_complete), _create_build_callback_error.bind(on_complete))

func _create_build_callback_success(response, on_complete: Callable):
	print("[HATHORA] Create build complete, running build in Hathora, this may take several minutes..")
	_config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	var build_api = BuildV1Api.new(_config)
	
	last_created_build_id = response.data["buildId"]
	
	var file = FileAccess.open(HathoraProjectSettings.get_s("path_to_tar_file"), FileAccess.READ)
	if not file:
		print("[HATHORA] Tar file not found")
		on_complete.call(true)
		return
	var file_content = file.get_buffer(file.get_length())
	_build_api.run_build(HathoraProjectSettings.get_s("application_id"), last_created_build_id, file_content, _run_build_callback_success.bind(on_complete), _run_build_callback_error.bind(on_complete))
	
func _run_build_callback_success(response, on_complete: Callable):
	print("[HATHORA] Run build complete, creating deployment")
	_config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	var deployment_api = DeploymentV1Api.new(_config)
	
	var deployment_config := DeploymentConfig.new()
	deployment_config.planName = %DeploymentSettings.plan_size
	deployment_config.roomsPerProcess = %DeploymentSettings.rooms_per_process
	deployment_config.transportType = %DeploymentSettings.transport_type
	deployment_config.containerPort = %DeploymentSettings.container_port
	deployment_config.env = []
	# This would automatically update the Deployment Settings, but we do not care because they are remporarily set to read only
	%LatestDeploymentGetter.get_latest_deployment()
	var data = await %LatestDeploymentGetter.updated_deployment
	# The API returns resource arrays, which we need to transform into an array of dictionaries
	if "env" in data:
		var arr:= []
		for env in data.env:
			arr.append(env.bzz_normalize())
		deployment_config.env = arr
	if "additionalContainerPorts" in data:
		var arr:= []
		for container_port in data.additionalContainerPorts:
			arr.append(container_port.bzz_normalize())
		deployment_config.additionalContainerPorts = arr
	deployment_api.create_deployment(HathoraProjectSettings.get_s("application_id"), last_created_build_id, deployment_config, _create_deployment_callback_success.bind(on_complete), _create_deployment_callback_error.bind(on_complete))

func _create_deployment_callback_success(response, on_complete: Callable):
	on_complete.call(false)
	print("[HATHORA] Create deployment complete, new version deployed successfully: " + str(response.data.deploymentId))
	# Wait for 2 seconds otherwise the API does not find the latest deployment
	await get_tree().create_timer(2.0)
	%LatestDeploymentGetter.get_latest_deployment()
	
func _create_deployment_callback_error(err, on_complete: Callable):
	on_complete.call(true)
	if err.response_code == 401:
		owner.reset_token()
	print("[HATHORA] "+str(err))

func _create_build_callback_error(err: Variant, on_complete: Callable):
	on_complete.call(true)
	print(err.response_code)
	if err.response_code == 401:
		owner.reset_token()
	print("[HATHORA] "+str(err))
	
func _run_build_callback_error(err, on_complete: Callable):
	# Ignoring the no response error...
	if not err.identifier == "apibee.request.no_response":
		on_complete.call(true)
		print("[HATHORA] "+str(err))
	if err.response_code == 401:
		owner.reset_token()
