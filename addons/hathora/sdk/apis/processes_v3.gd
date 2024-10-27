extends "endpoint.gd"

## Operations to get data on active and stopped processes.

## Retrieve the 10 most recent processes objects for an application. Filter the array by optionally passing in a status or region.
## [br][br]Returns an array. See [method get_process] for the data contained in each element of the array.
func get_latest(statuses: Array[Hathora.ProcessStatus] = [], regions: Array[Hathora.Region] = []):
	return GET("processes/latest", empty_array_stripped({
		"status": to_array_string(statuses, Hathora.PROCESS_STATUSES),
		"region": to_array_string(regions, Hathora.REGION_NAMES)})).then(func(result):
		if result.is_error():
			return result
		return result
	)

## Count the number of processes objects for an application. Filter by optionally passing in a status or region.
## [br][br]Returns process count: [float]
func get_count(statuses: Array[Hathora.ProcessStatus] = [], regions: Array[Hathora.Region] = []):
	return GET("processes/count", empty_array_stripped({
		"status": to_array_string(statuses, Hathora.PROCESS_STATUSES),
		"region": to_array_string(regions, Hathora.REGION_NAMES)})).then(func(result):
		if result.is_error():
			return result
		return result
	)

## Creates a process without a room. Use this to pre-allocate processes ahead of time so that subsequent room assignment via CreateRoom() can be instant.
## [br][br]See [method get_process] for the data contained in the result.
func create(region: Hathora.Region):
	return POST("processes/regions/" + Hathora.REGION_NAMES[region]).then(func(result):
		if result.is_error():
			return result
		return result
	)

## Get details for a process
## [br][br][br][b]If successful, calls to this endpoint return:[/b]
## [br][br][code]status[/code]: [enum Hathora.ProcessStatus]. Status of the process.
## [br][br][code]roomsAllocated[/code]: [float]. Tracks the number of rooms that have been allocated to the process.
## [br][br][code]terminatedAt[/code]: [String] or [code]null[/code]. When the process has been terminated.
## [br][br][code]stoppingAt[/code]: [String] or [code]null[/code]. When the process is issued to stop. Used to determine when billing should stop.
## [br][br][code]startedAt[/code]: [String] or [code]null[/code]. When the process bound to the specified port. Used to determine when billing should start.
## [br][br][code]createdAt[/code]: [String] <date-time>. When the process started being provisioned.
## [br][br][code]roomsPerProcess[/code]: [float][ 1 .. 10000 ]. Governs how many rooms can be scheduled in a process.
## [br][br][code]additionalExposedPorts[/code]: [Array] of dictionaries. Connection details for up to 2 exposed ports.
## [br][br][code]exposedPort[/code]: [Dictionary] or [code]null[/code]. Connection details for an active process.
## [br][br][code]region[/code]: [enum Hathora.Region].
## [br][br][code]processId[/code]: [String]. System generated unique identifier to a runtime instance of your game server.
## [br][br][code]deploymentId[/code]: [float]. System generated id for a deployment. Increments by 1.
## [br][br][code]appId[/code]: [String]. System generated unique identifier for an application.
func get_process(process_id: String):
	return GET("processes/" + process_id).then(func(result):
		if result.is_error():
			return result
		return result
		)

## Stops a process immediately
func stop(process_id: String):
	return POST("processes/" + process_id + "/stop").then(func(result):
		if result.is_error():
			return result
		return result
	)
