@tool
extends Node

const DotEnv = preload("../dotenv.gd")

const CLIENT_ID = "tWjDhuzPmuIWrI8R9s3yV3BQVw2tW0yq";
const AUTH0_DOMAIN = "https://auth.hathora.com";
const AUDIENCE_URI = "https://cloud.hathora.com";

var isReady = false
var device_code: String
var interval_timer: Timer
var temp: String


func _ready():
	DotEnv.config()
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
		var response = j.parse(body.get_string_from_utf8())
		var access_token = j.data["access_token"]
		var id_token = j.data["id_token"]

		# Use the access_token and id_token as needed
		print("[HATHORA] Storing access token in the config file as HATHORA_DEVELOPER_TOKEN")
		DotEnv.add("HATHORA_DEVELOPER_TOKEN", access_token)
		
		# Login completed, trigger callback
		if login_complete_cb:
			login_complete_cb.call(true)

		# Stop polling for token
		interval_timer.stop()
		interval_timer.queue_free()
	elif (response_code == 400 || response_code == 403):
		# Token not yet available, continue polling
		pass
	else:
		print("[HATHORA] Token request failed with response code:", response_code)		
		# Stop polling for token
		interval_timer.stop()
		interval_timer.queue_free()
