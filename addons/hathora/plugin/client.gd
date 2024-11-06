@tool
extends Node

const _Builds = preload("res://addons/hathora/plugin/apis/builds_v3.gd")
const _Deployments = preload("res://addons/hathora/plugin/apis/deployments_v3.gd")
const _Apps = preload("res://addons/hathora/plugin/apis/apps_v2.gd")
const _Room = preload("res://addons/hathora/plugin/apis/room_v2.gd")
const _Client = preload("res://addons/hathora/plugin/rest-client/client.gd")
const _HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const _DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")


var builds_v3: _Builds
var room_v2: _Room
var deployments_v3: _Deployments
var apps_v2: _Apps
var client : _Client

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
	deployments_v3 = _Deployments.new(_dev_client, "/deployments/v3/apps")
	builds_v3 = _Builds.new(_dev_client, "/builds/v3/")
	apps_v2 = _Apps.new(_dev_client, "/apps/v2/")
	room_v2 = _Room.new(_dev_client, "/rooms/v2/".path_join(app_id))
	# Setting the dev token if found in DotEnv
	if not _DotEnv.get_k("HATHORA_DEVELOPER_TOKEN").is_empty():
		set_dev_token(_DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	# Player endpoints

## Set a [param dev_token]. Not recommended, specify the devToken at [code]res://.hathora/config[/code] or at [code]res://hathora_config[/code] instead.
## [br][br][b]Warning:[/b] the devToken gives privileged access to your Hathora account. Never include the devToken in client builds or in your versioning system.
func set_dev_token(dev_token: String) -> void:
	_dev_client.set_header("Authorization", "Bearer " + dev_token)

func set_app_id(app_id: String) -> void:
	room_v2 = _Room.new(_dev_client, "/rooms/v2/".path_join(app_id))
