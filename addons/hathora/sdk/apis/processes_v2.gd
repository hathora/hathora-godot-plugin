extends "endpoint.gd"

func get_info(process_id: String):
	return GET("/info/" + process_id).then(func (result):
		if result.is_error():
			return result
		return result
	)

func get_latest(status : Hathora.ProcessStatus = -1, region : Hathora.Region = -1):
	return GET("/list/latest", empty_string_stripped({
		"status": Hathora.PROCESS_STATUSES.get(status, ""),
		"region": Hathora.REGION_NAMES.get(region, "")})).then(func (result):
		if result.is_error():
			return result
		return result
	)
