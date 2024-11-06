## SDK to interact with the Hathora API.
## @tutorial: https://hathora.dev/docs/engines/godot
## @tutorial: https://hathora.dev/api
## See the properties for the documentation of each endpoint.
## [br][br]Example usage:
## [codeblock]
## var last_error = ""
##
## func create_lobby() -> bool:
##      last_error = ""
## 
##      # Create a public lobby using a previously obtained playerAuth token
##      # The function will pause until a result is obtained
##      var res = await HathoraSDK.lobby_v3.create(login_token, Hathora.Visibility.PUBLIC, Hathora.Region.FRANKFURT).async()
## 
##      # Having obtained a result, the function continues
##      # If there was an error, store the error message and return
##      if res.is_error():
##           last_error = res.as_error().message
##           return false
## 
##      # Store the data contained in the Result
##      lobby_data = res.get_data()
##      print("Created lobby with roomId ", lobby_data.roomId)
##      return true
## [/codeblock]

extends Node

const _Client = preload("../sdk/rest-client/client.gd")
const _Lobby = preload("../sdk/apis/lobby_v3.gd")
const _Room = preload("../sdk/apis/room_v2.gd")
const _Auth = preload("../sdk/apis/auth_v1.gd")
const _Processes = preload("../sdk/apis/processes_v3.gd")
const _Discovery = preload("../sdk/apis/discovery_v2.gd")
const _DotEnv = preload("../sdk/dotenv.gd")
const _HathoraProjectSettings = preload("res://addons/hathora/sdk/hathora_project_settings.gd")

## Operations to create and manage lobbies using our Lobby Service.
var lobby_v3 : _Lobby

## Operations to create, manage, and connect to rooms.
var room_v2 : _Room

## Operations that allow you to generate a Hathora-signed JSON web token (JWT) for player authentication.
var auth_v1 : _Auth

## Operations to get data on active and stopped processes.
var processes_v3 : _Processes

## Service that allows clients to directly ping all Hathora regions to get latency information
var discovery_v2 : _Discovery

var _no_auth_client: _Client
var _player_client: _Client
var _dev_client : _Client

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_DotEnv.config()
	var node = self
	var url = "https://api.hathora.dev"
	var app_id = _HathoraProjectSettings.get_s("application_id")
	var tls_options = null
	
	# Dev endpoints
	_dev_client = _Client.new(node, url, {}, tls_options)
	room_v2 = _Room.new(_dev_client, "/rooms/v2/".path_join(app_id))
	processes_v3 = _Processes.new(_dev_client, "/processes/v3/apps".path_join(app_id))
	# Setting the dev token if found in DotEnv
	if not _DotEnv.get_k("HATHORA_DEVELOPER_TOKEN").is_empty():
		set_dev_token(_DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	# Player endpoints
	_player_client = _Client.new(node, url, {}, tls_options)
	lobby_v3 = _Lobby.new(_player_client, "/lobby/v3/".path_join(app_id))
	discovery_v2 = _Discovery.new(_player_client, "/discovery/v2/")
	auth_v1 = _Auth.new(_player_client, "/auth/v1/".path_join(app_id))

## Set a [param dev_token]. Not recommended, specify the devToken at [code]res://.hathora/config[/code] or at [code]res://hathora_config[/code] instead.
## [br][br][b]Warning:[/b] the devToken gives privileged access to your Hathora account. Never include the devToken in client builds or in your versioning system.
func set_dev_token(dev_token: String) -> void:
	_dev_client.set_header("Authorization", "Bearer " + dev_token)

## Set an [param app_id]. Not recommended, specify the appId in the Godot ProjectSettings instead.
func set_app_id(app_id: String) -> void:
	room_v2 = _Room.new(_dev_client, "/rooms/v2/".path_join(app_id))
	processes_v3 = _Processes.new(_dev_client, "/processes/v3/apps".path_join(app_id))
	lobby_v3 = _Lobby.new(_player_client, "/lobby/v3/".path_join(app_id))
	auth_v1 = _Auth.new(_no_auth_client, "/auth/v1/".path_join(app_id))

## Set [param tls_options] for the SDK client.
func set_tls_options(tls_options: TLSOptions) -> void:
	_dev_client.default_tls_options = tls_options
	_player_client.default_tls_options = tls_options
	_no_auth_client.default_tls_options = tls_options
