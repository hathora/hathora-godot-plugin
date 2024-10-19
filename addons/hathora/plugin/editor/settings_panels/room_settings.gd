@tool
extends "../settings_panel.gd"


const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")
const Enums = preload("res://addons/hathora/plugin/enums.gd")

@onready var sdk = %SDK

var selected_region:String:
	get: return region_n.get_item_text(region_n.selected)

var region_n: OptionButton
var room_id_n: LineEdit
var host_n: LineEdit
var port_n: LineEdit

func _make_settings() -> void:
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	region_n = add_option_button("Region", REGIONS)
	room_id_n = add_line_edit_with_icon("Room ID", "", get_theme_icon("ActionCopy", "EditorIcons"), _on_room_id_copy_button_pressed)
	host_n = add_line_edit_with_icon("Host", "", get_theme_icon("ActionCopy", "EditorIcons"), _on_host_copy_button_pressed)
	port_n = add_line_edit_with_icon("Port", "", get_theme_icon("ActionCopy", "EditorIcons"), _on_port_copy_button_pressed)
	room_id_n.editable = false
	host_n.editable = false
	port_n.editable = false
	add_button("Create Room", get_theme_icon("Add", "EditorIcons"), _on_create_room_button_pressed)
	
func _on_create_room_button_pressed():
	if not selected_region:
		print("[HATHORA] Selected Region required")
		return
	if HathoraProjectSettings.get_s("application_id").is_empty():
		print("[HATHORA] No application selected")
		return
	print("[HATHORA] Create room requested...")
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	
	if Enums.REGION_NAMES.find_key(selected_region) == null:
		print("[HATHORA] Invalid region")
		return
	var res = await sdk.room_v2.create(Enums.REGION_NAMES.find_key(selected_region)).async()
	
	if res.is_error():
		print("[HATHORA] Error creating a room")
		print(res.as_error())
		if res.as_error().error == 401:
			owner.reset_token()
		return
	
	var room_id = res.get_data().roomId
	print("[HATHORA] Created a new room with roomId: ", room_id)
	room_id_n.text = room_id
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	_get_connection_info(room_id)

func _get_connection_info(room_id: String) -> void:
	host_n.text = "Polling..."
	port_n.text = "Polling..."
	
	var res = await sdk.room_v2.get_connection_info(room_id).async()
	
	if res.is_error():
		print(res.as_error())
		return
	
	var info = res.get_data()
	
	if info.status != Enums.RoomStatus.ACTIVE:
		_get_connection_info(room_id)
		return
	
	host_n.text = str(res.exposedPort.host)
	port_n.text = str(res.exposedPort.port)

func _on_room_id_copy_button_pressed() -> void:
	if not room_id_n.text.is_empty():
		DisplayServer.clipboard_set(room_id_n.text)
		
func _on_host_copy_button_pressed() -> void:
	if not host_n.text.is_empty():
		DisplayServer.clipboard_set(host_n.text)
		
func _on_port_copy_button_pressed() -> void:
	if not port_n.text.is_empty():
		DisplayServer.clipboard_set(port_n.text)
