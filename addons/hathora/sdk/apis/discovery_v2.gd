## Service that allows clients to directly ping all Hathora regions to get latency information
extends "endpoint.gd"

## Returns an array of all regions with a host and port that a client can directly ping.
## Open a websocket connection to [code]wss://<host>:<port>/ws[/code] and send a packet. To calculate ping, measure the time it takes to get an echo packet back.
## [br][br][br][b]If successful, calls to this endpoint return:[/b]
## [br][br] [Array] of dictionaries. Each element contains:
## [br]-- [code]port[/code]: [float]
## [br]-- [code]host[/code]: [String]
## [br]-- [code]name[/code]: [String]
func get_ping_service_endpoints():
	return GET("ping").then(func (result):
		if result.is_error():
			return result
		# New regions may be added to the API, which are unknown to the Godot SDK
		# They get parsed as null, and we filter them out in this endpoint
		var data = result.get_data()
		var http_result = result.get_http_result()
		var data_unknown_regions_removed = data.filter(func(entry):return entry.region != null)
		return PolyResult.new(data_unknown_regions_removed, http_result)
		)
