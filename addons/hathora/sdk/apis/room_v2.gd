extends "endpoint.gd"

## Operations to create, manage, and connect to rooms.

## Create a new room for an existing application.
## Poll the [method get_info] endpoint to get connection details for an active room.
## Takes:
## [br][br]- [param room_config]: [Dictionary]. Optional configuration parameters for the room. It is accessible from the room via [method get_info].
## [br][br]- [param region]: [enum Hathora.Region]
## [br][br]- optionally [param room_id][i][ 1 .. 100 ] characters ^[a-zA-Z0-9_-]*$[/i] which overrides the system generated one
## [br][br][b]Note:[/b] error will be returned if roomId is not globally unique.
## [br][br][br][b]If successful, calls to this endpoint return:[/b]
## [br][br]- [code]additionalExposedPorts[/code][i]<= 2 items[/i]: [Array]. Each element contains:
## [br]-- [code]transportType[/code]:[enum Hathora.TransportType]. Transport type specifies the underlying communication protocol to the exposed port.
## [br]-- [code]port[/code]:[float]
## [br]-- [code]host[/code]:[String]
## [br]-- [code]name[/code]:[String]
## [br][br] [code]exposedPort[/code]:[Dictionary] containing:
## [br]-- [code]transportType[/code]:[enum Hathora.TransportType]. Transport type specifies the underlying communication protocol to the exposed port.
## [br]-- [code]port[/code]:[float]
## [br]-- [code]host[/code]:[String]
## [br]-- [code]name[/code]:[String]
## [br][br] [code]status[/code]:[enum Hathora.RoomStatus]
## [br][br] [code]roomId[/code]:[String]
## [br][br] [code]processId[/code]:[String]
func create(room_config: Dictionary, region: Hathora.Region, room_id = ""):
	return POST("create", {
		"roomConfig": JSON.stringify(room_config),
		"region": Hathora.REGION_NAMES[region]
	},
	empty_string_stripped({"roomId": room_id})).then(func (result):
		if result.is_error():
			return result
		return result
	)

## Retreive current and historical allocation data for a room.
## [br][br][br][b]If successful, calls to this endpoint return:[/b]
## [br][br]- [code]currentAllocation[/code]: [Dictionary] containing:
## [br]-- [code]unscheduledAt[/code]:[String] <date-time>
## [br]-- [code]scheduledAt[/code]:[String]
## [br]-- [code]processId[/code]:[String]. System generated unique identifier to a runtime instance of your game server.
## [br]-- [code]roomAllocationId[/code]:[String]. System generated unique identifier to an allocated instance of a room.
## [br][br] [code]status[/code]:[enum Hathora.RoomStatus]
## [br][br]- [code]allocations[/code]: [Array]. Each element contains:
## [br]-- [code]unscheduledAt[/code]:[String] <date-time>
## [br]-- [code]scheduledAt[/code]:[String]
## [br]-- [code]processId[/code]:[String]. System generated unique identifier to a runtime instance of your game server.
## [br]-- [code]roomAllocationId[/code]:[String]. System generated unique identifier to an allocated instance of a room.
## [br][br] [code]roomConfig[/code]:[String]
## [br][br] [code]roomId[/code]:[String]
## [br][br] [code]appId[/code]:[String]
func get_info(room_id: String):
	return GET("info/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)
	
## Get all active rooms for a given [param process_id].
## [br][br][br][b]If successful, calls to this endpoint return an [Array] containing:[/b]
## [br]-- [code]appId[/code]:[String]
## [br]-- [code]roomId[/code]:[String]
## [br]-- [code]roomConfig[/code]:[String]
## [br]-- [code]status[/code]:[enum Hathora.RoomStatus]
## [br][br]- [code]currentAllocation[/code]: [Dictionary]
func get_active(process_id: String):
	return GET("list/" + process_id + "/active").then(func (result):
		if result.is_error():
			return result
		return result
		)

## Get all inactive rooms for a given [param process_id].
func get_inactive(process_id: String):
	return GET("list/" + process_id + "/inactive").then(func (result):
		if result.is_error():
			return result
		return result
		)

## Destroy a room by its [param room_id]. All associated metadata is deleted.
func destroy(room_id: String):
	return POST("destroy/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)

## [b]Deprecated[/b]
## [br]Suspend a room. The room is unallocated from the process but can be rescheduled later using the same roomId.
func suspend(room_id: String):
	return POST("suspend/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)

## Poll this endpoint to get connection details to a room. Clients can call this endpoint without authentication.
func get_connection_info(room_id: String):
	return GET("connectioninfo/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)
		
		
func update_config(room_id: String):
	return POST("update/" + room_id).then(func (result):
		if result.is_error():
			return result
		return result
		)	
	
	
