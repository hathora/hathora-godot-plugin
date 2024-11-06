@tool
extends EditorPlugin

const DotEnv = preload("../plugin/dotenv.gd")
const BASE = "hathora"
const HathoraProjectSettings = preload("hathora_project_settings.gd")
# MARK: Plugin
var control_ui: Control

func _enter_tree():
	HathoraProjectSettings.add_project_settings()
	control_ui = preload("editor/control_ui.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, control_ui)

	
func _exit_tree():
	# Remove control ui
	remove_control_from_docks(control_ui)
	control_ui.free()
	# Remove project settings
	HathoraProjectSettings.erase_project_settings()
