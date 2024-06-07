@tool
extends HBoxContainer

func _ready() -> void:
	$Console.icon = get_theme_icon("Tools", "EditorIcons")
	$Docs.icon = get_theme_icon("Help", "EditorIcons")
	$Discord.icon = get_theme_icon("ExternalLink", "EditorIcons")
	$Docs.get_popup().set_item_icon(0, get_theme_icon("ExternalLink", "EditorIcons"))
	$Docs.get_popup().set_item_icon(1, get_theme_icon("Help", "EditorIcons"))
	$Docs.get_popup().index_pressed.connect(_on_docs_popup_index_pressed)
	$Docs.get_popup().set_item_disabled(1, not FileAccess.file_exists("res://addons/hathora/sdk/client.gd"))
	
func _on_console_pressed() -> void:
	OS.shell_open("https://console.hathora.dev/")

func _on_tutorial_pressed() -> void:
	OS.shell_open("https://hathora.dev/docs/engines/godot")

func _on_docs_popup_index_pressed(index: int) -> void:
	match index:
		0:
			OS.shell_open("https://hathora.dev/docs/engines/godot")
		1:
			# See https://github.com/godotengine/godot/issues/72406 for why we are doing this
			var script_paths = [
				"res://addons/hathora/sdk/client.gd", 
				"res://addons/hathora/sdk/apis/auth_v1.gd",
				"res://addons/hathora/sdk/apis/discovery_v2.gd",
				"res://addons/hathora/sdk/apis/lobby_v3.gd",
				"res://addons/hathora/sdk/apis/processes_v2.gd",
				"res://addons/hathora/sdk/apis/room_v2.gd"]
			for path in script_paths:
				var script = load(path)

				# Make a small change and save it to refresh the documentation
				if script:
					ResourceSaver.save(script, path)
					
			EditorInterface.get_script_editor().goto_help("class_name:HathoraSDK")
			

func _on_discord_pressed() -> void:
	OS.shell_open("https://discord.com/invite/hathora")
