extends "endpoint.gd"

func create(room_config: Dictionary, region: Hathora.Region, room_id = ""):
	return POST("/create", {
		"roomConfig": JSON.stringify(room_config),
		"region": Hathora.REGION_NAMES[region]
	},
	empty_string_stripped({"roomId": room_id})).then(func (result):
		if result.is_error():
			return result
		return result
	)


func get_info(room_id: String):
	return GET("/info/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)
	
		
func get_active(process_id: String):
	return GET("/list/" + process_id + "/active").then(func (result):
		if result.is_error():
			return result
		return result
		)


func get_inactive(process_id: String):
	return GET("/list/" + process_id + "/inactive").then(func (result):
		if result.is_error():
			return result
		return result
		)


func destroy(room_id: String):
	return POST("/destroy/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)


func suspend(room_id: String):
	return POST("/suspend/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)


func get_connection_info(room_id: String):
	return GET("/connectioninfo/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)
		
		
func update_config(room_id: String):
	return POST("/update/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)	
	
	
