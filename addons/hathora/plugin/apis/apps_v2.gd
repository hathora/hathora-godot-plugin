extends "endpoint.gd"


func get_apps(org_id: String = ""):
	return GET("apps", empty_string_stripped({"orgId": org_id})).then(func (result):
		if result.is_error():
			return result
		return result
		)

func create(auth_config: String, app_name: String, org_id: String = ""):
	return POST("apps", empty_string_stripped({
		"authConfiguration": auth_config,
		"appName": app_name,
		"orgId": org_id})).then(func (result):
		if result.is_error():
			return result
		return result
		)
	
func update(app_id: String, auth_config: String, app_name: String):
	return POST("apps/" + app_id, {
		"authConfiguration": auth_config,
		"appName": app_name}).then(func (result):
		if result.is_error():
			return result
		return result
		)

func get_app(app_id: String):
	return GET("apps/" + app_id).then(func (result):
		if result.is_error():
			return result
		return result
		)

func delete(app_id: String):
	return DELETE("apps/" + app_id).then(func (result):
		if result.is_error():
			return result
		return result
		)
