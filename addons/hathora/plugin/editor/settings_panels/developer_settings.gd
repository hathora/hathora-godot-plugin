@tool
extends "../settings_panel.gd"

const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")
const ApiConfig = preload("res://addons/hathora/plugin/core/ApiConfig.gd")
const AppV1Api = preload("res://addons/hathora/plugin/apis/AppV1Api.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")

var config: ApiConfig

var dev_token : String :
	set(v):
		if read_only: return
		dev_token = v
		dev_token_n.text = v
		dev_token_n.text_changed.emit(v)
	get: return dev_token_n.text
		
var app_dictionary: Dictionary
var app_names: Array[String]
var selected_app_id: String :
	get:
		if target_app_n.get_selected_metadata():
			return target_app_n.get_selected_metadata()
		return ""
	set(v):
		if read_only: return
		selected_app_id = v
		for i in range(target_app_n.item_count):
			if target_app_n.get_item_metadata(i) == v:
				target_app_n.select(i)

var dev_token_n : LineEdit
var target_app_n : OptionButton
var login_button_n: Button


func _make_settings() -> void:
	dev_token_n = add_line_edit_with_icon("Developer token", DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"), get_theme_icon("GuiVisibilityVisible", "EditorIcons"), _on_dev_token_visibility_button_pressed)
	dev_token_n.secret = true
	dev_token_n.text_changed.connect(_on_dev_token_text_changed)
	target_app_n = add_option_button_with_icon("Target application", [], get_theme_icon("Reload", "EditorIcons"), refresh_applications)
	target_app_n.item_selected.connect(_on_app_selected)
	login_button_n = add_button("Login with another account", get_theme_icon("CryptoKey", "EditorIcons"), owner._on_login_button_pressed)
	config = ApiConfig.new()
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	if DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"):
		refresh_applications()
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)

func _on_project_settings_changed() -> void:
	selected_app_id = HathoraProjectSettings.get_s("application_id")

func add_app(p_app_name: String, p_app_id: String) -> void:
	if not p_app_name.is_empty() and not p_app_id.is_empty():
		target_app_n.add_item(p_app_name)
		var i = target_app_n.item_count - 1
		target_app_n.set_item_metadata(i, p_app_id)


func clear_apps() -> void:
	target_app_n.clear()


func _on_app_selected(index:int) -> void:
	HathoraProjectSettings.set_s("application_id", selected_app_id)
	%LatestDeploymentGetter.get_latest_deployment()

	
func refresh_applications() -> void:
	# Update config, in case user has since logged in
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	var appApi = AppV1Api.new(config)
	appApi.get_apps(_get_apps_callback_success, _get_apps_callback_error)

	
func _get_apps_callback_success(response) -> void:
	# Clear existing apps
	clear_apps()
	# If the user has no applications
	if len(response.data) == 0:
		target_app_n.add_item("No applications found")
		target_app_n.set_item_disabled(0, true)
		target_app_n.selected = target_app_n.get_selectable_item()
		print("[HATHORA] No applications found, create a new one at console.hathora.dev")
		%LatestDeploymentTextEdit.text = "No applications found, create a new one at console.hathora.dev"
		return
		
	for application in response.data:
		add_app(application.appName, application.appId)
		
	target_app_n.selected = target_app_n.get_selectable_item()
	
	# If we have an appId in our environment, try to select that app
	if not HathoraProjectSettings.get_s("application_id").is_empty():
		for i in range(target_app_n.item_count):
			if target_app_n.get_item_metadata(i) == HathoraProjectSettings.get_s("build_directory_path"):
				target_app_n.select(i)
	
	_on_app_selected(target_app_n.selected)


func _get_apps_callback_error(err) -> void:
	clear_apps()
	%LatestDeploymentTextEdit.text = "Error getting latest deployment information"
	print("[HATHORA] " + str(err))
	if err.response_code == 401:
		owner.reset_token()


# Toggle dev token secret
func _on_dev_token_visibility_button_pressed() -> void:
	dev_token_n.secret = !dev_token_n.secret


func _on_dev_token_text_changed(new_text: String) -> void:
	DotEnv.add("HATHORA_DEVELOPER_TOKEN", dev_token)
	if len(new_text) == 842:
		# Automatically refresh the applications when a new token is inserted
		refresh_applications()
		login_button_n.text = "Login with another account"
	else:
		login_button_n.text = "Login to Hathora"
