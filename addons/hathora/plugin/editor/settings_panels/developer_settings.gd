@tool
extends "../settings_panel.gd"

const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")

@onready var sdk = %SDK
@onready var room_section_toggle: Button = %RoomSectionToggle

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
				break

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
	
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
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
	target_app_n.disabled = false
	target_app_n.tooltip_text = ""


func _on_app_selected(index:int) -> void:
	HathoraProjectSettings.set_s("application_id", selected_app_id)
	%SDK.set_app_id(selected_app_id)
	%LatestDeploymentGetter.get_latest_deployment()

	
func refresh_applications() -> void:
	room_section_toggle.disabled = false
	room_section_toggle.tooltip_text = ""
	# Update config, in case user has since logged in
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	var res = await sdk.apps_v2.get_apps().async()
	if res.is_error():
		clear_apps()
		%LatestDeploymentTextEdit.text = "Error getting latest deployment information"
		print(res.as_error())
		if res.as_error().error == 401:
			owner.reset_token()
		return
	clear_apps()
	var apps = res.get_data().applications
	# If the user has no applications
	if len(apps) == 0:
		print_rich("[HATHORA] No applications found, create a new one at [url=http://console.hathora.dev]console.hathora.dev[/url]")
		target_app_n.disabled = true
		target_app_n.tooltip_text = "No applications found"
		HathoraProjectSettings.set_s("application_id", "")
		
		room_section_toggle.button_pressed = false
		room_section_toggle.disabled = true
		room_section_toggle.tooltip_text = "No target application selected"
		
		%LatestDeploymentTextEdit.text = "No applications found, create a new one at console.hathora.dev"
		return
	for app in apps:
		add_app(app.appName, app.appId)
		
	target_app_n.selected = target_app_n.get_selectable_item()
	
	# If we have an appId in our environment, try to select that app
	if not HathoraProjectSettings.get_s("application_id").is_empty():
		for i in range(target_app_n.item_count):
			if target_app_n.get_item_metadata(i) == HathoraProjectSettings.get_s("application_id"):
				target_app_n.select(i)
				break
	
	_on_app_selected(target_app_n.selected)


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
