@tool
extends RefCounted
const BASE = "hathora"

static func _add_project_setting(name: String, type: int, default, hint = null, hint_string = null) -> void:
	if ProjectSettings.get_setting(name, "").is_empty():
		ProjectSettings.set_setting(name, default)
		
	ProjectSettings.set_initial_value(name, default)
	ProjectSettings.set_as_basic(name, true)
	
	var info := {
		name = name,
		type = type,
	}
	if hint != null:
		info['hint'] = hint
	if hint_string != null:
		info['hint_string'] = hint_string

	ProjectSettings.add_property_info(info)
	
static func _erase_project_setting(name: String, type: int, default, hint = null, hint_string = null) -> void:
	if ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)

static func add_project_settings() -> void:
	_add_project_setting('hathora/application_id', TYPE_STRING, "")
	_add_project_setting('hathora/path_to_tar_file', TYPE_STRING, "res://.hathora/builds/game_server.tgz", PROPERTY_HINT_FILE, "*.tar.tgz,*.tgz,*.tar.gz")
	_add_project_setting('hathora/build_directory_path', TYPE_STRING, "res://.hathora/builds", PROPERTY_HINT_DIR)
	_add_project_setting('hathora/build_filename', TYPE_STRING, "game_server.pck")

static func erase_project_settings() -> void:
	_erase_project_setting('hathora/application_id', TYPE_STRING, "")
	_erase_project_setting('hathora/path_to_tar_file', TYPE_STRING, "")
	_erase_project_setting('hathora/build_directory_path', TYPE_STRING, "")
	_erase_project_setting('hathora/build_filename', TYPE_STRING, "")

static func get_s(key, def=""):
	var fk = "%s/%s" % [BASE, key]
	return ProjectSettings.get_setting(fk) if ProjectSettings.has_setting(fk) else def

static func set_s(key, value, save=true):
	var fk = "%s/%s" % [BASE, key]
	ProjectSettings.set_setting(fk, value)
	if save:
		ProjectSettings.save()

static func set_m(key, value):
	var es = EditorInterface.get_editor_settings()
	es.set_project_metadata("hathora", key, value)
