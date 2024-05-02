extends "endpoint.gd"

func login_anonymous():
	return POST("/login/anonymous").then(func (result):
		if result.is_error():
			return result
		return result
		)
		
func login_nickname(nickname: String):
	return POST("/login/nickname", {
		"nickname": nickname
	}).then(func (result):
		if result.is_error():
			return result
		return result
		)

func login_google(id_token: String):
	return POST("/login/google", {
		"idToken": id_token
	}).then(func (result):
		if result.is_error():
			return result
		return result
		)
