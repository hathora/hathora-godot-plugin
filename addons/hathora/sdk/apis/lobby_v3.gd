extends "endpoint.gd"

func create(player_token: String, visibility: Hathora.Visibility, region: Hathora.Region, room_config = {}, short_code = "", room_id = ""):
	client.set_header("Authorization", "Bearer " + player_token)
	return POST("/create", {
		"visibility": Hathora.VISIBILITY[visibility],
		"roomConfig": JSON.stringify(room_config),
		"region": Hathora.REGION_NAMES[region]
	}, empty_string_stripped({
		"shortCode": short_code,
		"roomId": room_id
		})).then(func (result):
			
		if result.is_error():
			return result
		return result
	)


func list_active_public(player_token: String, region: Hathora.Region = -1):
	client.set_header("Authorization", "Bearer " + player_token)
	return GET("/list/public", empty_string_stripped({"region": Hathora.REGION_NAMES.get(region, "")})).then(func (result):
		if result.is_error():
			return result
		return result
	)
	
	
func get_info_by_room_id(player_token: String, room_id: String):
	client.set_header("Authorization", "Bearer " + player_token)
	return GET("/info/roomid/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
	)


func get_info_by_short_code(player_token: String, short_code: String):
	client.set_header("Authorization", "Bearer " + player_token)
	return GET("/info/shortcode/" + short_code).then(func (result):
		if result.is_error():
			return result
		return result
	)
	
	
