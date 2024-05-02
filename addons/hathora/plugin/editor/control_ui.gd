@tool
extends Node

const DotEnv = preload("../dotenv.gd")
const HathoraProjectSettings = preload("../hathora_project_settings.gd")
const Auth0Client = preload("../auth0/auth0Client.gd")

var auth0Client: Auth0Client

func _ready():
	auth0Client = Auth0Client.new()
	add_child(auth0Client)
	%LoginContent.visible = should_show_login_content()
	%MainContentPanel.visible = !should_show_login_content()
	%MainContentPanel.add_theme_stylebox_override("panel", %MainContentPanel.get_theme_stylebox("panel", "EditorValidationPanel"))

func should_show_login_content() -> bool:
	return DotEnv.get_k("HATHORA_DEVELOPER_TOKEN").is_empty()


func _on_login_button_pressed():
	auth0Client.get_token_async(_login_complete_callback)


func _login_complete_callback(success: bool):
	%LoginContent.visible = should_show_login_content()
	%MainContentPanel.visible = !should_show_login_content()
	%DeveloperSettings.dev_token = DotEnv.get_k("HATHORA_DEVELOPER_TOKEN")
	%DeveloperSettings.refresh_applications()

# We call this function whenver the token becomes invalid
func reset_token() -> void:
	%DeveloperSettings.dev_token = ""
	print("[HATHORA] Invalid developer token, please press the login button or paste a valid token in the Developer Settings")
	%DeveloperSectionToggle.button_pressed = true
	%DeveloperSettings.dev_token_n.grab_focus()
