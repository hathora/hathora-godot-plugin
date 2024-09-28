#TODO: test with 0 applications
@tool
extends Node

signal updated_deployment(data)

const _Builds = preload("res://addons/hathora/plugin/apis/builds_v3.gd")
const _Deployments = preload("res://addons/hathora/plugin/apis/deployments_v3.gd")
const _Client = preload("res://addons/hathora/plugin/rest-client/client.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")

@onready var sdk = %SDK
var last_created_build_id: String

func get_latest_deployment() -> Dictionary:
	sdk.set_dev_token(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))


	if HathoraProjectSettings.get_s("application_id").is_empty():
		return {}
	%LatestDeploymentTextEdit.text = "Getting latest deployment information..."
	var res = await sdk.deployments_v3.get_deployments(HathoraProjectSettings.get_s("application_id")).async()
	
	if res.is_error():
		print("[HATHORA] Error getting the latest deployment")
		print(res.as_error())
		if res.as_error().error == 401:
			owner.reset_token()
		return {}
	res = res.get_data()
	if len(res.deployments) == 0:
		%LatestDeploymentTextEdit.text = "No deployments found"
		return {}
	updated_deployment.emit(res.deployments[0])
	return res.deployments[0]
