extends "endpoint.gd"

func get_deployments(app_id: String):
	return GET(app_id + "/deployments").then(func (result):
		if result.is_error():
			return result
		return result
		)

func create(app_id: String, deployment_config: Dictionary):
	return POST(app_id + "/deployments", deployment_config).then(func (result):
		if result.is_error():
			return result
		return result
		)

func get_latest(app_id: String):
	return GET(app_id + "/deployments/latest").then(func (result):
		if result.is_error():
			return result
		return result
		)

func get_deployment(app_id: String, deployment_id: String):
	return GET(app_id + "/deployments/" + deployment_id).then(func (result):
		if result.is_error():
			return result
		return result
		)
