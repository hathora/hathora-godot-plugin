@tool
extends "../settings_panel.gd"

const ApiConfig = preload("res://addons/hathora/plugin/core/ApiConfig.gd")
const RoomV2Api = preload("res://addons/hathora/plugin/apis/RoomV2Api.gd")
const CreateRoomRequest = preload("res://addons/hathora/plugin/models/CreateRoomRequest.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")

var config: ApiConfig

var selected_region:String:
	get: return region_n.get_item_text(region_n.selected)

var region_n: OptionButton
var room_id_n: LineEdit
var host_n: LineEdit
var port_n: LineEdit

func _make_settings() -> void:
	config = ApiConfig.new()
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
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
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	var room_api = RoomV2Api.new(config)

	var create_room_request := CreateRoomRequest.new()
	create_room_request.region = selected_region
	
	room_api.create_room(HathoraProjectSettings.get_s("application_id"), create_room_request, "", _create_room_callback_success, _create_room_callback_error)
	
func _create_room_callback_success(response):
	print("[HATHORA] Created a new room with roomId: ", response.data.roomId)
	room_id_n.text = response.data.roomId
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	_get_connection_info(response.data.roomId)
	host_n.text = "Polling..."
	port_n.text = "Polling..."
	
func _get_connection_info(room_id: String):
	var room_api = RoomV2Api.new(config)
	room_api.get_connection_info(HathoraProjectSettings.get_s("application_id"), room_id, _get_connecton_info_callback_success, _get_connecton_info_callback_error)
	
func _get_connecton_info_callback_success(response):
	if response.data.status != "active":
		_get_connection_info(response.data.roomId)
		return
	host_n.text = str(response.data.exposedPort.host)
	port_n.text = str(response.data.exposedPort.port)

func _get_connecton_info_callback_error(err):
	print("[HATHORA] " + str(err))
	host_n.text = ""
	port_n.text = ""
	if err.response_code == 401:
		owner.reset_token()
			
func _create_room_callback_error(err):
	print("[HATHORA] " + str(err))
	if err.response_code == 401:
		owner.reset_token()

func _on_room_id_copy_button_pressed() -> void:
	if not room_id_n.text.is_empty():
		DisplayServer.clipboard_set(room_id_n.text)
		
func _on_host_copy_button_pressed() -> void:
	if not host_n.text.is_empty():
		DisplayServer.clipboard_set(host_n.text)
		
func _on_port_copy_button_pressed() -> void:
	if not port_n.text.is_empty():
		DisplayServer.clipboard_set(port_n.text)
