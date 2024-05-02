Hathora Godot
===========
This Godot addon includes:
* Hathora editor plugin to configure, build, and deploy your server directly from the Godot editor
* Hathora GDScript SDK for programmatic integration

<img src="images/hathora_plugin_screenshot.png"/>

This README covers:
* [Installation](#installation)
* [First deployment](#first-deployment)
* [SDK endpoints](#sdk-endpoints)
* [Configuration](#configuration)
* [Calling API endpoints](#calling-api-endpoints)
* [SDK Example usage](#sdk-example-usage)

## Installation
There are two ways to get the addon:
1. AssetLib: simply open your Godot project and download "Hathora Godot" from the AssetLib. Choose whether to install the SDK, the plugin, or both

2. GitHub releases page: download the addon, unzip, and move the resulting folder to your Godot project root. The contents of the addon should be at `<your-project-root>/addons/hathora`

After installing the addon, open the Project Settings, and enable it under the Plugins tab.

<img src="images/enable_plugin.png" width="600" />

## First deployment
### 1. Press `Login to Hathora` and complete the login on the browser window that opens

<img src="images/login_account.png" width="400" />

### 2. Press `Console` to open the Hathora Console and create a new application

<img src="images/create_app_1.png" width="400" />
<img src="images/create_app_2.png" width="600" />

### 3. Refresh the target applications in the plugin, your newly created application will appear

<img src="images/select_target.png" width="400" />

### 4. Create an export preset for your game
The plugin supports Linux x86_64 or Linux x86_32 export presets

> [!TIP]
> For instructios on how to set up your export preset, see [Godot's tutorial on exporting for dedicated servers](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_dedicated_servers.html)

### 5. Refresh the export presets in the plugin
Your newly created export preset will appear

<img src="images/build_deploy.png" width="400" />

### 6. Press `Generate Server Build`
### 7. Inspect the logs
Ensure the build was successful
### 8. Adjust the Deployment Settings
The container port should match the port your server is listening on. In Godot, the server port is usually specified when calling the create_server function on an ENetMultiplayerPeer instance, like so:
```gdscript
const SERVER_PORT = 7777

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()

	# The container port in the Hathora Deployment Settings should match SERVER_PORT
	var error = peer.create_server(SERVER_PORT, MAX_CONNECTIONS)
	if error:
		return
	multiplayer.multiplayer_peer = peer
```
### 9. Press `Deploy to Hathora`
The plugin will automatically upload your server build to Hathora. It may take a few minutes.
### 10. Press `Create Room`
Connect to the given host and port to test your new build

## SDK endpoints
The SDK includes a HathoraSDK autoload, with the following functions:
* room_v2
	* create
	* get_info
	* get_active
	* get_inactive
	* destroy
	* suspend
	* get_connection_info
	* update_config
* auth_v1
	* login_anonymous
	* login_nickname
	* login_google
* lobby_v3
	* create
	* list_active_public
	* get_info_by_room_id
	* get_info_by_short_code
* processes_v2
	* get_info
	* get_latest
* discovery_v1
	* get_ping_service_endpoints

For more information, see the [Hathora API documentation](http://hathora.dev/api).
## Configuration
Configuration is saved in two locations: the appId is in the Godot project settings, and the devToken is in the config gile `<project-root>/.hathora/config`.
### Specifying an appId
The SDK uses the appId specified under `Project Settings > Hathora > App Id`. When you select a target application in the plugin, its appId is automatically applied to the project settings. Alternatively, you can specify an appId by calling `HathoraSDK.set_app_id(app_id)`.

### Specifying a devToken

> [!WARNING]
> The devToken gives priviledged access to your Hathora account. Never include the devToken in client builds or in your versioning system.

When the SDK or the plugin are enabled in your project for the first time, a config file is generated at `<project-root>/.hathora/config`. For endpoints that require it, the SDK uses the devToken specified at `<project-root>/.hathora/config`. You may edit this file manually, or by using the plugin (`Developer Settings > Developer token`). Alternatively, you can call `HathoraSDK.set_dev_token(dev_token)`. By default, Godot project exports will omit the config file. If `Include Hathora config` is enabled while generating a server build through the plugin, a copy of the devToken will be saved at `<project-root>/hathora_config`.

## Calling API endpoints
```gdscript
func create_lobby() -> bool:
	last_error = ""

	# Create a public lobby using a previously obtained playerAuth token
	# The function will pause until a result is obtained
	var lobby_result = await HathoraSDK.lobby_v3.create(login_token, Hathora.Visibility.PUBLIC, Hathora.Region.FRANKFURT, {}).async()
	
	# Having obtained a result, the function continues
	# If there was an error, store the error message and return
	if lobby_result.is_error():
		last_error = lobby_result.as_error().message
		return false

	# Store the data contained in the Result
	lobby_data = result.get_data()
	print("Created lobby with roomId ", lobby_data.roomId)
	return true
```
Note the `async()` call. Calling `HathoraSDK.lobby_v3.create()` returns a Request object. Calling `async()` on the Request object allows you to pause the execution of the function by using the `await` keyword, until a result is obtained. The `is_error()` function returns true if there was an error. Finally, `lobby_result.as_error().message` allows you to store the error message and display it to the user. All endpoints contained in the SDK can be called using this pattern.

## SDK Example usage
This snippet shows how to login and join a lobby by its shortCode:
```gdscript
var player_nickname = "Nickname"
var lobby_short_code = "1234"
var token:= ""

# Player requesting to join a lobby
func _on_join_lobby_requested() -> void:
	# Logging in the player
	if token.is_empty():
		var res = await HathoraSDK.auth_v1.login_nickname(player_nickname).async()
		if res.is_error():
			print(res.as_error().message)
			return

		token = res.get_data().token
	
	# Getting the roomId from the lobby shortCode
	var res = await HathoraSDK.lobby_v3.get_info_by_short_code(token, lobby_short_code).async()
	if res.is_error():
		print(res.as_error().message)
		return

	join_room_id(res.get_data().roomId)
	
# Joining the room by its roomId
func join_room_id(room_id: String) -> void:
	
	# Getting the connection info for the room
	var res = await HathoraSDK.room_v2.get_connection_info(room_id).async()
	if res.is_error():
		print(res.as_error().message)
		return

	var connection_info = res.get_data()

	# If the roomStatus is not yet ACTIVE, we try again
	if connection_info.status != Hathora.RoomStatus.ACTIVE:
		join_room_id(room_id)
		return
	
	# Creating a multiplayer peer using the exposed host and port
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(connection_info.exposedPort.host, connection_info.exposedPort.port)
	if err:
		print(str(err))
		return

	multiplayer.multiplayer_peer = peer
	await multiplayer.connected_to_server
	print("Connected!")
```
## Questions?

Get help and ask questions in our active Discord community:
[https://discord.com/invite/hathora](https://discord.com/invite/hathora)

## Version compatibility

This addon is compatible with Godot 4.X
