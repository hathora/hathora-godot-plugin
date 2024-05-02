extends Node

const Client = preload("../sdk/rest-client/client.gd")
const Lobby = preload("../sdk/apis/lobby_v3.gd")
const Room = preload("../sdk/apis/room_v2.gd")
const Auth = preload("../sdk/apis/auth_v1.gd")
const Processes = preload("../sdk/apis/processes_v2.gd")
const Discovery = preload("../sdk/apis/discovery_v1.gd")
const DotEnv = preload("../sdk/dotenv.gd")
const HathoraProjectSettings = preload("res://addons/hathora/sdk/hathora_project_settings.gd")

var lobby_v3 : Lobby
var room_v2 : Room
var auth_v1 : Auth
var processes_v2 : Processes
var discovery_v1 : Discovery

var no_auth_client: Client
var player_client: Client
var dev_client : Client

var log_function: Callable

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	DotEnv.config()
	var node = self
	var url = "https://api.hathora.dev"
	var app_id = HathoraProjectSettings.get_s("application_id")
	var tls_options = null
	
	# Dev endpoints
	dev_client = Client.new(node, url, {}, tls_options)
	room_v2 = Room.new(dev_client, "/rooms/v2/" + app_id)
	processes_v2 = Processes.new(dev_client, "/processes/v2/" + app_id)
	# Setting the dev token if found in DotEnv
	if not DotEnv.get_k("HATHORA_DEVELOPER_TOKEN").is_empty():
		set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	# Player endpoints
	player_client = Client.new(node, url, {}, tls_options)
	lobby_v3 = Lobby.new(player_client, "/lobby/v3/" + app_id)
	discovery_v1 = Discovery.new(player_client, "/discovery/v1")
	auth_v1 = Auth.new(player_client, "/auth/v1/" + app_id)


func set_dev_token(dev_token: String) -> void:
	dev_client.set_header("Authorization", "Bearer " + dev_token)


func set_app_id(app_id: String) -> void:
	room_v2 = Room.new(dev_client, "/rooms/v2/" + app_id)
	processes_v2 = Processes.new(dev_client, "/processes/v2/" + app_id)
	lobby_v3 = Lobby.new(player_client, "/lobby/v3/" + app_id)
	auth_v1 = Auth.new(no_auth_client, "/auth/v1/" + app_id)


func set_tls_options(tls_options: TLSOptions) -> void:
	dev_client.default_tls_options = tls_options
	player_client.default_tls_options = tls_options
	no_auth_client.default_tls_options = tls_options
	
	
# Log and debug functions
func debug(msg) -> void:
	if log_function.is_valid(): log_function.call(0, msg)


func warning(msg) -> void:
	if log_function.is_valid(): log_function.call(1, msg)


func error(msg) -> void:
	if log_function.is_valid(): log_function.call(2, msg)


func fail() -> void:
	breakpoint
	pass
