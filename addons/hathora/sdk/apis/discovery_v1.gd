extends "endpoint.gd"

func get_ping_service_endpoints():
	return GET("/ping/").then(func (result):
		if result.is_error():
			return result
		# New regions may be added to the API, which are unknown to the Godot SDK
		# They get parsed as null, and we filter them out in this endpoint
		var data = result.get_data()
		var http_result = result.get_http_result()
		var data_unknown_regions_removed = data.filter(func(entry):return entry.region != null)
		return PolyResult.new(data_unknown_regions_removed, http_result)
		)
