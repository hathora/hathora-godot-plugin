extends "endpoint.gd"

## Operations to create, manage, and connect to processes.

## Get details for a process.
## [br][br][br][b]If successful, calls to this endpoint return:[/b]
## [br][br][code]status[/code]: [enum Hathora.ProcessStatus]. Status of the process.
## [br][br][code]roomsAllocated[/code]: [float]. Tracks the number of rooms that have been allocated to the process.
## [br][br][code]terminatedAt[/code]: [String]. When the process has been terminated.
## [br][br][code]stoppingAt[/code]: [String]. When the process is issued to stop. Used to determine when billing should stop.
## [br][br][code]startedAt[/code]: [String]. When the process bound to the specified port. Used to determine when billing should start.
## [br][br][code]createdAt[/code]: [String]. When the process started being provisioned.
## [br][br][code]roomsPerProcess[/code]: [float][ 1 .. 10000 ]. Governs how many rooms can be scheduled in a process.
## [br][br][code]additionalExposedPorts[/code]: [Array]. Connection details for up to 2 exposed ports.
## [br][br][code]exposedPort[/code]: [Dictionary]. Connection details for an active process.
## [br][br][code]region[/code]: [enum Hathora.Region].
## [br][br][code]processId[/code]: [String]. System generated unique identifier to a runtime instance of your game server.
## [br][br][code]deploymentId[/code]: [float]. System generated id for a deployment. Increments by 1.
## [br][br][code]appId[/code]: [String]. System generated unique identifier for an application.
func get_info(process_id: String):
	return GET("info/" + process_id).then(func (result):
		if result.is_error():
			return result
		return result
	)

## Retrieve an Array containing the 10 most recent processes objects for an application.
## Filter the array by optionally passing in a [param status]([enum Hathora.ProcessStatus]) or [param region] ([enum Hathora.Region]). For the contents of the elements of the array, see [method get_info]
func get_latest(status : Hathora.ProcessStatus = -1, region : Hathora.Region = -1):
	return GET("list/latest", empty_string_stripped({
		"status": Hathora.PROCESS_STATUSES.get(status, ""),
		"region": Hathora.REGION_NAMES.get(region, "")})).then(func (result):
		if result.is_error():
			return result
		return result
	)
