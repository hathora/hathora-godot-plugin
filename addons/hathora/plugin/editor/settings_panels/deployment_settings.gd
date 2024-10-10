@tool
extends "../settings_panel.gd"

const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")

var requested_cpu: float:
	set(v):
		if read_only: return
		requested_cpu = v
		requested_cpu_n.value = v
	get: return requested_cpu_n.value
	
var requested_memory: float:
	set(v):
		if read_only: return
		requested_memory = v
		requested_memory_n.value = v
	get: return requested_memory_n.value

var path_to_tar: String:
	set(v):
		if read_only: return
		path_to_tar = v
		var car = tar_file_n.caret_column
		tar_file_n.text = v
		tar_file_n.caret_column = car
		#tar_file_n.text_changed.emit(v)
	get: return tar_file_n.text
	
var rooms_per_process: int:
	set(v):
		if read_only: return
		rooms_per_process = v
		rooms_per_process_n.value = v
	get: return rooms_per_process_n.value

var transport_type: String:
	set(v):
		if read_only: return
		transport_type = v
		for i in range(transport_type_n.item_count):
			if transport_type_n.get_item_text(i) == v:
				transport_type_n.select(i)
	get: return transport_type_n.get_item_text(transport_type_n.selected)
	
var container_port: int:
	set(v):
		if read_only: return
		container_port = v
		container_port_n.value = v
	get: return container_port_n.value

var tar_file_n: LineEdit
var requested_cpu_n: SpinBox
var requested_memory_n: SpinBox
var rooms_per_process_n: SpinBox
var transport_type_n: OptionButton
var container_port_n: SpinBox
var deploy_n: Button

func _make_settings() -> void:
	tar_file_n = add_line_edit_with_icon("Path to tar file", HathoraProjectSettings.get_s("path_to_tar_file"), get_theme_icon("Folder", "EditorIcons"), _on_file_dialog_button_pressed)
	tar_file_n.text_changed.connect(_on_tar_file_text_changed)
	
	requested_cpu_n = add_spinbox("CPU (cores)", 0.5, 4, 0.1)
	requested_cpu_n.value_changed.connect(_on_cpu_value_changed)
	
	requested_memory_n = add_spinbox("Memory (GB)", 1, 8, 0.2)
	requested_memory_n.value_changed.connect(_on_memory_value_changed)
	
	rooms_per_process_n = add_spinbox("Rooms per process", 1, 10000, 1.0)
	
	transport_type_n = add_option_button("Transport type", TRANSPORT_TYPES)
	
	container_port_n = add_spinbox("Container port", 1, 65535, 1.0)
	
	deploy_n = add_button("Deploy to Hathora", get_theme_icon("Environment", "EditorIcons"), _on_deploy_button_pressed)
	
	var font_size = max(get_theme_font_size("main_size", "EditorFonts") - 4, 4)
	add_rich_text_label("[center][font_size=%d]For more advanced configuration: [url=http://console.hathora.dev]Hathora Console[/url][/font_size][/center]" % font_size, _on_label_meta_clicked)
	
	%LatestDeploymentGetter.updated_deployment.connect(_on_updated_deployment)
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)
	
func _on_file_dialog_button_pressed() -> void:
	%PathToTarFileDialog.current_dir = path_to_tar.get_base_dir()
	%PathToTarFileDialog.show()
	
func _on_label_meta_clicked(link: Variant) -> void:
	if link is String:
		OS.shell_open(link)

func _on_updated_deployment(data: Variant) -> void:
	# If there is no data on the latest deployment, we set some defaults
	if not "buildId" in data:
		requested_cpu = 0.5
		requested_memory = 1
		rooms_per_process = 1
		transport_type = "udp"
		container_port = 7777
		return
		
	requested_cpu = data.requestedCPU
	requested_memory = data.requestedMemoryMB / 1024
	container_port = data.defaultContainerPort.port
	transport_type = data.defaultContainerPort.transportType
	rooms_per_process = data.roomsPerProcess

func _on_tar_file_text_changed(_new_text: String):
	HathoraProjectSettings.set_s("path_to_tar_file", path_to_tar)


func _on_project_settings_changed():
	path_to_tar = HathoraProjectSettings.get_s("path_to_tar_file")
	

func _on_deploy_button_pressed() -> void:
	# Validate params
	if DotEnv.get_k("HATHORA_DEVELOPER_TOKEN").is_empty():
		print("[HATHORA] Need valid developer token to deploy")
		return
	if HathoraProjectSettings.get_s("build_directory_path").is_empty():
		print("[HATHORA] Need valid build directory path")
		return
	if HathoraProjectSettings.get_s("path_to_tar_file").is_empty():
		print("[HATHORA] Need valid path to tar file")
		return

	# Create Build
	# The BuildDeployer calls LatestDeploymentGetter to get env and additionalPorts, just before deploying
	# This call would automatically override any Deployment Settings set by the user
	# To avoid Deployment Settings getting overridden, we set them to read only until the deployment is complete
	read_only = true
	
	await get_tree().process_frame
	print("[HATHORA] Create build started")
	var err = await %BuildDeployer.do_upload_and_create_build()
	
	if err:
		print_rich("[color=%s][HATHORA] [b]DEPLOYMENT ERROR at %s [/b][/color]" % [get_theme_color("error_color", "Editor").to_html(), Time.get_time_string_from_system()])
	else:
		print_rich("[color=%s][HATHORA] [b]DEPLOYMENT SUCCESS at %s [/b][/color]" % [get_theme_color("success_color", "Editor").to_html(), Time.get_time_string_from_system()])
	read_only = false

func _on_cpu_value_changed(v: float) -> void:
	requested_memory_n.set_value_no_signal(v*2)
	return

func _on_memory_value_changed(v: float) -> void:
	requested_cpu_n.set_value_no_signal(v/2)
	return
