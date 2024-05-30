extends "endpoint.gd"

## Operations that allow you to generate a Hathora-signed JSON web token (JWT) for player authentication.

## Returns a unique player token for an anonymous user.
func login_anonymous():
	return POST("login/anonymous").then(func (result):
		if result.is_error():
			return result
		return result
		)
	
## Returns a unique player token with a specified nickname for a user.	
func login_nickname(nickname: String):
	return POST("login/nickname", {
		"nickname": nickname
	}).then(func (result):
		if result.is_error():
			return result
		return result
		)

## Returns a unique player token using a Google-signed OIDC idToken.
func login_google(id_token: String):
	return POST("login/google", {
		"idToken": id_token
	}).then(func (result):
		if result.is_error():
			return result
		return result
		)
