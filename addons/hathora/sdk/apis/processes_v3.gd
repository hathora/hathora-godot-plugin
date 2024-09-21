extends "endpoint.gd"

## Retrieves the 10 most recent processes for an app, optionally filtered by status and region
func get_latest(app_id: String, status: Array = [], region: Array = []):
	return GET("processes/v3/apps/" + app_id + "/processes/latest", {
		"status": status,
		"region": region}).then(func(result):
		if result.is_error():
			return result
		return result
	)

## Count the number of processes objects for an application. Filter by optionally passing in a status or region.
func get_count(app_id: String, status: Array = [], region: Array = []):
	return GET("processes/v3/apps/" + app_id + "/processes/count", {
		"status": status,
		"region": region}).then(func(result):
		if result.is_error():
			return result
		return result
	)

# Creates a process in a specific region for an app
func create(app_id: String, region: String):
	return POST("processes/v3/apps/" + app_id + "/processes/regions/" + region).then(func(result):
		if result.is_error():
			return result
		return result
	)

# Retrieves details for a specific process
func get_process(app_id: String, process_id: String):
	return GET("processes/v3/apps/" + app_id + "/processes/" + process_id).then(func(result):
		if result.is_error():
			return result
		return result
	)

# Stops a specific process
func stop(app_id: String, process_id: String):
	return POST("processes/v3/apps/" + app_id + "/processes/" + process_id + "/stop").then(func(result):
		if result.is_error():
			return result
		return result
	)
