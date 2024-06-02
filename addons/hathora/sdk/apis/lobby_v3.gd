extends "endpoint.gd"

## Operations to create and manage lobbies using Harhora's Lobby Service.

## Create a new lobby for an application.
## A lobby object is a wrapper around a room object.
## With a lobby, you get additional functionality like
## configuring the visibility of the room,
## managing the state of a match,
## and retrieving a list of public lobbies to display to players.
## Takes:
## [br][br]- [param player_token]: [String]
## [br][br]- [param visibility]: [enum Hathora.Visibility]
## [br][br]- [param region]: [enum Hathora.Region]
## [br][br]- optionally [param room_config]: [String]. Optional configuration parameters for the room. It is accessible from the room via [method HathoraSDK.room_v2.get_info].
## [br][br]- optionally [param short_code] for a user-defined identifier for a lobby, for example: [code]"LFG4"[/code]
## [br][br]- optionally [param room_id]([ 1 .. 100 ] characters ^[a-zA-Z0-9_-]*$) which overrides the system generated one
## [br][br][b]Note:[/b] error will be returned if roomId is not globally unique.
## [br][br][br][b]If successful, calls to this endpoint return:[/b]
## [br][br]- [code]shortCode[/code]: [String] (<= 100 characters). User-defined identifier for a lobby.
## [br][br]- [code]createdAt[/code]: [String] <date-time>. When the lobby was created.
## [br][br]- [code]createdBy[/code]: [String]. UserId or email address for the user that created the lobby.
## [br][br]- [code]roomConfig[/code]: [String](<= 10000 characters) or [code]null[/code]. Optional configuration parameters for the room. Can be any string including stringified JSON. It is accessible from the room via [method HathoraSDK.room_v2.get_info].
## [br][br]- [code]visibility[/code]: [enum Hathora.Visibility]
## [br][br]- [code]region[/code]: [enum Hathora.Region]
## [br][br]- [code]roomId[/code]: [String] ([ 1 .. 100 ] characters ^[a-zA-Z0-9_-]*$).
## [br][br]- [code]appId[/code]: [String]
func create(player_token: String, visibility: Hathora.Visibility, region: Hathora.Region, room_config := "", short_code := "", room_id := ""):
	client.set_header("Authorization", "Bearer " + player_token)
	return POST("create", empty_string_stripped({
		"visibility": Hathora.VISIBILITY[visibility],
		"region": Hathora.REGION_NAMES[region],
		"roomConfig": room_config,
	}), empty_string_stripped({
		"shortCode": short_code,
		"roomId": room_id,
		})).then(func (result):	
		if result.is_error():
			return result
		return result
	)

## Get an [Array] containing all active lobbies for a given application.
## Filter the [Array] by optionally passing in a [param region].
## Use this endpoint to display all public lobbies that a player can join in the game client.
## See [method create] for the data contained in each element of the array.
func list_active_public(player_token: String, region: Hathora.Region = -1):
	client.set_header("Authorization", "Bearer " + player_token)
	return GET("list/public", empty_string_stripped({"region": Hathora.REGION_NAMES.get(region, "")})).then(func (result):
		if result.is_error():
			return result
		return result
	)
	
## Get details for a lobby.
## See [method create] for the data contained in the result.
func get_info_by_room_id(player_token: String, room_id: String):
	client.set_header("Authorization", "Bearer " + player_token)
	return GET("info/roomid" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
	)

## Get details for a lobby. If 2 or more lobbies have the same [param shortCode], then the most recently created lobby will be returned.
## See [method create] for the data contained in the result.
func get_info_by_short_code(player_token: String, short_code: String):
	client.set_header("Authorization", "Bearer " + player_token)
	return GET("info/shortcode" + short_code).then(func (result):
		if result.is_error():
			return result
		return result
	)
	
	
