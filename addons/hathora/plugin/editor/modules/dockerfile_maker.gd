@tool
extends Node
## Takes a Dockerfile template txt file, inserts ENV variables and saves to disk

func write_dockerfile(build_filename: String, path: String, overwrite: bool = false, debug: bool = false):
	# The Dockerfile template txt file
	var docker_template_file = FileAccess.open("res://addons/hathora/plugin/dockerfile_template.txt", FileAccess.READ)
	
	if not docker_template_file:
		var error = FileAccess.get_open_error()
		push_error("[HATHORA] Error opening Dockerfile template: "+error_string(error))
		return false
	
	var docker_template_content = docker_template_file.get_as_text()
	var godot_version = str(Engine.get_version_info().major) + "." + str(Engine.get_version_info().minor) + "." + str(Engine.get_version_info().patch)
	
	var custom_dockerfile = docker_template_content.format({
		"godot_release_url": get_godot_release_url(),
		"godot_release_filename": get_godot_release_filename(),
		"build_file": build_filename})
	
	if FileAccess.file_exists(path) and not overwrite:
		print("[HATHORA] Dockerfile found, will not overwrite")
		return true
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		push_error("[HATHORA] Error creating Dockerfile: " + error_string(FileAccess.get_open_error()))
		return false
	
	file.store_string(custom_dockerfile)
	file.close()
	var absolute_path = ProjectSettings.globalize_path(path)
	print_rich("[color=%s][HATHORA] Dockerfile generated at [url=%s]%s[/url]" % [owner.get_theme_color("success_color", "Editor").to_html(), absolute_path, absolute_path])
	
	return true
	
# 4.2.1-stable
func get_godot_release() -> String:
	var v_info = Engine.get_version_info()
	var str: String = "{major}.{minor}{patch}-{status}".format(
		{
			"major" = v_info.major,
			"minor" = v_info.minor,
			"patch" = "." + str(v_info.patch) if v_info.patch > 0 else "",
			"status" = v_info.status}
	)
	return str

# Godot_v4.2.1-stable_linux.x86_64
func get_godot_release_filename() -> String:
	var v_info = Engine.get_version_info()
	var str: String = "Godot_v{godot_release}_linux.x86_64".format(
		{
			"godot_release" = get_godot_release(),
		})
	return str

# https://github.com/godotengine/godot-builds/releases/download/4.3-dev5/Godot_v4.3-dev5_linux.x86_64.zip
func get_godot_release_url() -> String:
	var v_info = Engine.get_version_info()
	var str = "https://github.com/godotengine/godot-builds/releases/download/{godot_release}/{godot_release_filename}.zip".format(
		{
			"godot_release" = get_godot_release(),
			"godot_release_filename" = get_godot_release_filename(),
		})
	return str
