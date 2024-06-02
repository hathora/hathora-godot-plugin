@tool
extends "../settings_panel.gd"

const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")
const EXPORT_PRESETS_PATH = 'res://export_presets.cfg'
const CONFIG_PATH = "res://.hathora/config"
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")

var build_dir_path : String :
	set(v):
		build_dir_path = v
		build_dir_n.text = v
	get: return build_dir_n.text

var build_filename : String :
	set(v):
		build_filename = v
		build_filename_n.text = v
	get: return build_filename_n.text

var selected_preset: String:
	get: return export_preset_n.get_item_text(export_preset_n.selected)

var generate_tar_file: bool:
	get: return generate_tar_n.button_pressed

var overwrite_dockerfile: bool:
	get: return overwrite_df_n.button_pressed
	
var include_config: bool:
	get: return include_config_n.button_pressed

var build_dir_n: LineEdit
var build_filename_n: LineEdit
var export_preset_n: OptionButton
var overwrite_df_n: CheckBox
var include_config_n: CheckBox
var generate_tar_n: CheckBox

func _make_settings() -> void:
	build_dir_n = add_line_edit_with_icon("Build directory", HathoraProjectSettings.get_s("build_directory_path"), get_theme_icon("Folder", "EditorIcons"), _on_folder_button_pressed)
	build_dir_n.text_changed.connect(_on_build_dir_text_changed)
	build_filename_n = add_line_edit("Build filename", HathoraProjectSettings.get_s("build_filename"))
	build_filename_n.text_changed.connect(_on_build_filename_text_changed)
	export_preset_n = add_option_button_with_icon("Export preset", [], get_theme_icon("Reload", "EditorIcons"), update_export_presets)
	update_export_presets()
	overwrite_df_n = add_checkbox("Overwrite Dockerfile", "On")
	include_config_n = add_checkbox("Include Hathora config", "On")
	generate_tar_n = add_checkbox("Generate tar file", "On", true)
	add_button("Generate Server Build", get_theme_icon("Save", "EditorIcons"), _on_generate_server_build_button_pressed)
	#We add a spacer under the generate button, then move the build logs under it
	add_spacer(false)
	%BuildDirFileDialog.dir_selected.connect(_on_dir_selected)
	var i = get_child_count()
	add_spacer(false)
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)


func _on_build_dir_text_changed(_new_text: String) -> void:
	HathoraProjectSettings.set_s("build_directory_path", build_dir_path)

func _on_build_filename_text_changed(_new_text: String) -> void:
	HathoraProjectSettings.set_s("build_filename", build_filename)

func _on_project_settings_changed() -> void:
	build_dir_path = HathoraProjectSettings.get_s("build_directory_path")
	build_filename = HathoraProjectSettings.get_s("build_filename")
	
func update_export_presets() -> void:
	export_preset_n.clear()

	var file := ConfigFile.new()
	if file.load(EXPORT_PRESETS_PATH) != OK:
		return

	var presets := []
	for section in file.get_sections():
		if not file.has_section_key(section, 'name'):
			continue
		var platform = file.get_value(section, 'platform')
		# Only add Linux presets
		if platform != 'Linux' and platform != 'Linux/X11':
			continue
		var architecture = file.get_value(section + ".options", 'binary_format/architecture')
		presets.push_back({
			name = file.get_value(section, 'name'),
			dedicated_server = file.get_value(section, 'dedicated_server', false),
			architecture = architecture,
			# Only x86_64 and x86_32 supported
			architecture_supported = architecture == 'x86_64' or architecture == 'x86_32'
		})

	presets.sort_custom(func (a, b):
		if a['dedicated_server'] == b['dedicated_server']:
			return a['name'].nocasecmp_to(b['name']) <= 0
		return a['dedicated_server']
	)

	for preset in presets:
		export_preset_n.add_item(preset['name'])
		# Set disabled if the architecture is unsupported
		export_preset_n.set_item_disabled(export_preset_n.item_count - 1, not preset['architecture_supported'])
		
		if not preset['architecture_supported']:
			export_preset_n.set_item_text(export_preset_n.item_count - 1, preset['name'] + " (" + preset['architecture'] + " not supported)")
	
	export_preset_n.selected = export_preset_n.get_selectable_item()

func _on_generate_server_build_button_pressed():
	if ! await _generate_server_build():
		_print_fail()
	else:
		_print_success()


func _generate_server_build() -> bool:
	if HathoraProjectSettings.get_s("build_directory_path").is_empty():
		print("[HATHORA] Build directory path required")
		return false
	
	if not DirAccess.dir_exists_absolute(HathoraProjectSettings.get_s("build_directory_path")):
		print("[HATHORA] Build directory path does not exist")
		return false
	
	if HathoraProjectSettings.get_s("build_filename").is_empty():
		print("[HATHORA] Build filename required")
		return false
		
	if HathoraProjectSettings.get_s("build_filename").get_extension() != "pck":
		print("[HATHORA] Build filename must end in .pck")
		return false
		
	if %ServerBuildSettings.selected_preset.is_empty():
		print("[HATHORA] Must select an existing Linux export preset")
		return false
	
	var build_name : String = HathoraProjectSettings.get_s("build_filename")
	var build_dir_path : String = HathoraProjectSettings.get_s("build_directory_path")
	var build_name_no_ext : String = HathoraProjectSettings.get_s("build_filename").get_slice(".", 0)
	var export_preset = %ServerBuildSettings.selected_preset
	
	if ! await %DockerfileMaker.write_dockerfile(
		build_name,
		build_dir_path + "/Dockerfile",
		%ServerBuildSettings.overwrite_dockerfile):
		return false
	
	await get_tree().process_frame
	
	if ! await %ProjectExporter.export(build_name, build_dir_path, export_preset):
		return false
		
		
	await get_tree().process_frame
	
	# Put a copy of the config file (.hathora/config) in the root of the build directory
	if %ServerBuildSettings.include_config:
		if ! await copy_config_file(CONFIG_PATH, build_dir_path.path_join("hathora_config")):
			return false
	
	
	if %ServerBuildSettings.generate_tar_file:
		# Setting output tar path to HATHORA_BUILD_DIR_PATH+HATHORA_BUILD_FILENAME.tgz
		var output_tar_path = HathoraProjectSettings.get_s("build_directory_path").path_join(build_name_no_ext+".tgz")
		var file_names := ["Dockerfile", build_name]
		
		if %ServerBuildSettings.include_config:
			file_names.append("hathora_config")
			
		if ! await %TarMaker.tar_files(
			HathoraProjectSettings.get_s("build_directory_path"),
			build_name_no_ext+".tgz",
			# Adding Dockerfile, and PCK file to the tarball
			file_names
			):
			return false
			
			
		# Set the path to tar in the plugin UI to our new tarball path
		%DeploymentSettings.path_to_tar = output_tar_path
		HathoraProjectSettings.set_s("path_to_tar_file", output_tar_path)
		
		print("[HATHORA] Updated path to tar file in the Deployment Settings")
		return true
	return true


func _on_folder_button_pressed() -> void:
	%BuildDirFileDialog.current_dir = build_dir_path
	%BuildDirFileDialog.show()


func _on_dir_selected(dir: String) -> void:
	build_dir_path = dir
	HathoraProjectSettings.set_s("build_directory_path", dir)


func _print_success():
	print_rich("[color=%s][HATHORA] [b]BUILD SUCCESS at %s [/b][/color]" % [get_theme_color("success_color", "Editor").to_html(), Time.get_time_string_from_system()])


func _print_fail():
	print_rich("[color=%s][HATHORA] [b]BUILD ERROR at %s [/b][/color]" % [get_theme_color("error_color", "Editor").to_html(), Time.get_time_string_from_system()])


func copy_config_file(from_path: String, to_path: String) -> bool:
	var config = ConfigFile.new()
	var err = config.load(from_path)
	
	if err:
		print("[HATHORA] Could not find Hathora config file")
		return false

	err = config.save(to_path)
	
	if err != OK:
		print("[HATHORA] Error saving the config file")
		return false

	var absolute_output_path = ProjectSettings.globalize_path(to_path)
	print_rich("[color=%s][HATHORA] Saved Hathora config file at [url=%s]%s[/url][/color]" % [get_theme_color("success_color", "Editor").to_html(), absolute_output_path, absolute_output_path])
	return true
