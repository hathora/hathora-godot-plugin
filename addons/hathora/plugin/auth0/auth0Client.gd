@tool
extends Node

const DotEnv = preload("../dotenv.gd")

const CLIENT_ID = "tWjDhuzPmuIWrI8R9s3yV3BQVw2tW0yq";
const AUTH0_DOMAIN = "https://auth.hathora.com";
const AUDIENCE_URI = "https://cloud.hathora.com";
const HATHORA_API_BASE_URL = "https://api.hathora.dev";

var isReady = false
var device_code: String
var interval_timer: Timer
var temp: String


func _ready():
	if not isReady:
		start()


func start():
	isReady = true

func get_token_async(login_complete_cb: Callable) -> void:
	# Start the device authorization flow
	request_device_authorization(login_complete_cb)

func request_device_authorization(login_complete_cb: Callable) -> void:
	var url = AUTH0_DOMAIN + "/oauth/device/code"
	var body = {
		"client_id": CLIENT_ID,
		"scope": "openid profile email offline_access",
		"audience": AUDIENCE_URI
	}
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var err = http_request.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))
#	print(err)
	http_request.request_completed.connect(self._on_request_completed.bind(login_complete_cb))

func _on_request_completed(result, response_code, headers, body, login_complete_cb: Callable) -> void:
	if response_code == 200:
		var j = JSON.new()
		var response = j.parse(body.get_string_from_utf8())
		device_code = j.data["device_code"]
		var user_code = j.data["user_code"]
		var verification_uri = j.data["verification_uri"]
		var verification_uri_complete = j.data["verification_uri_complete"]

		# Display the user code and verification URL to the user
		print("[HATHORA] Please visit the following URL on your computer or mobile device: %s" % verification_uri_complete)
		print("[HATHORA] Confirm this same code is displayed: %s" % user_code)
		
		print("[HATHORA] Opening browser window..")
		OS.shell_open(verification_uri_complete)

		# Start polling for token
		interval_timer = Timer.new()
		interval_timer.set_wait_time(j.data["interval"])
		interval_timer.connect("timeout", poll_for_token.bind(login_complete_cb))
		add_child(interval_timer)
		interval_timer.start()
	else:
		print("[HATHORA] Device authorization request failed with response code:", response_code)

func poll_for_token(login_complete_cb: Callable) -> void:
	var url = AUTH0_DOMAIN + "/oauth/token"
	var body = {
		"grant_type": "urn:ietf:params:oauth:grant-type:device_code",
		"client_id": CLIENT_ID,
		"device_code": device_code
	}
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))
	http_request.request_completed.connect(self._on_token_received.bind(login_complete_cb))

func _on_token_received(result, response_code, headers, body, login_complete_cb: Callable) -> void:
	if response_code == 200:
		var j = JSON.new()
		var parse_result = j.parse(body.get_string_from_utf8())
		if parse_result != OK:
			print("[HATHORA] Failed to parse token response JSON")
			_cleanup_and_fail(login_complete_cb)
			return
			
		if not j.data.has("access_token") or not j.data.has("id_token"):
			print("[HATHORA] Expected token fields missing from response")
			_cleanup_and_fail(login_complete_cb)
			return
			
		var access_token = j.data["access_token"]
		var id_token = j.data["id_token"]
		
		print("[HATHORA] Authentication complete, beginning process to create Hathora API token")
		
		# Stop polling for token
		_cleanup_timer()
		
		get_orgs.bind(access_token, login_complete_cb).call()

	elif (response_code == 400 || response_code == 403):
		# Token not yet available, continue polling
		pass
	else:
		print("[HATHORA] Token request failed with response code:", response_code)		
		_cleanup_and_fail(login_complete_cb)

func _cleanup_timer() -> void:
	if interval_timer:
		interval_timer.stop()
		interval_timer.queue_free()
		interval_timer = null

func _cleanup_and_fail(login_complete_cb: Callable) -> void:
	_cleanup_timer()
	if login_complete_cb:
		login_complete_cb.call(false)

func get_orgs(access_token: String, login_complete_cb: Callable) -> void:
	var url = HATHORA_API_BASE_URL + "/orgs/v1"
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var auth_header = "Authorization: Bearer " + access_token
	var err = http_request.request(url, ["Content-Type: application/json", auth_header], HTTPClient.METHOD_GET)
	if err != OK:
		print("[HATHORA] Error making request to get orgs:", err)
		_cleanup_and_fail(login_complete_cb)
		http_request.queue_free()
		return
		
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			create_org_token(result, response_code, headers, body, access_token, login_complete_cb)
			http_request.queue_free()  # Clean up the request node
	)

func create_org_token(result, response_code, headers, body, access_token: String, login_complete_cb: Callable) -> void:
	if response_code != 200:
		print("[HATHORA] Get orgs request failed with response code:", response_code)
		_cleanup_and_fail(login_complete_cb)
		return
		
	var j = JSON.new()
	var parse_result = j.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("[HATHORA] Failed to parse orgs response JSON")
		_cleanup_and_fail(login_complete_cb)
		return
	
	if not j.data.has("orgs") or j.data["orgs"].size() == 0:
		print("[HATHORA] No organizations found in account")
		_cleanup_and_fail(login_complete_cb)
		return
		
	var org_id = j.data["orgs"][0]["orgId"]
	var org_scopes = j.data["orgs"][0]["scopes"]
	
	var url = HATHORA_API_BASE_URL + "/tokens/v1/orgs/" + org_id + "/create"
	var reqBody = {
		"scopes": org_scopes,
		"name": "godot-plugin-token_" + get_formatted_datetime()
	}
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var auth_header = "Authorization: Bearer " + access_token
	var err = http_request.request(url, ["Content-Type: application/json", auth_header], HTTPClient.METHOD_POST, JSON.stringify(reqBody))
	if err != OK:
		print("[HATHORA] Error making request to create token:", err)
		_cleanup_and_fail(login_complete_cb)
		http_request.queue_free()
		return
		
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			_create_org_token_completed(result, response_code, headers, body, login_complete_cb)
			http_request.queue_free()  # Clean up the request node
	)

func _create_org_token_completed(result, response_code, headers, body, login_complete_cb: Callable) -> void:
	if response_code >= 200 && response_code < 300:
		var j = JSON.new()
		var parse_result = j.parse(body.get_string_from_utf8())
		if parse_result != OK:
			print("[HATHORA] Failed to parse token creation response JSON")
			_cleanup_and_fail(login_complete_cb)
			return
			
		if not j.data.has("plainTextToken"):
			print("[HATHORA] Token field missing from response")
			_cleanup_and_fail(login_complete_cb)
			return
			
		var org_token = j.data["plainTextToken"]
		print("[HATHORA] Successfully created and stored Hathora API token")
		DotEnv.add("HATHORA_DEVELOPER_TOKEN", org_token)
		
		# Login completed, trigger callback
		login_complete_cb.call(true)
	else:
		print("[HATHORA] Create Hathora API token request failed with response code:", response_code)
		_cleanup_and_fail(login_complete_cb)

func get_formatted_datetime() -> String:
	var dt = Time.get_datetime_dict_from_system()
	return "%02d-%02d-%04d_%02d:%02d:%02d" % [dt.month, dt.day, dt.year, dt.hour, dt.minute, dt.second]
