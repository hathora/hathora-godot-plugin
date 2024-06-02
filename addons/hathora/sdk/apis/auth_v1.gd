## Operations that allow you to generate a Hathora-signed JSON web token (JWT) for player authentication.
extends "endpoint.gd"
## Returns a unique player token for an anonymous user.
##[br][br]Example usage:
##[codeblock]
## var token := ""
## 
## func player_login() -> void:
##     var res = await HathoraSDK.auth_v1.login_anonymous().async()
##     if res.is_error():
##         print("Login error: ", res.as_error().message)
##         return
##     token = res.get_data().token
##[/codeblock]
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
