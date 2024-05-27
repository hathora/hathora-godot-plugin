@tool
extends Node

signal updated_deployment(data)

const ApiConfig = preload("res://addons/hathora/plugin/core/ApiConfig.gd")
const DeploymentV1Api = preload("res://addons/hathora/plugin/apis/DeploymentV1Api.gd")
const HathoraProjectSettings = preload("res://addons/hathora/plugin/hathora_project_settings.gd")
const DotEnv = preload("res://addons/hathora/plugin/dotenv.gd")

var config: ApiConfig

func _ready() -> void:
	config = ApiConfig.new()
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	
func get_latest_deployment() -> void:
	if HathoraProjectSettings.get_s("application_id").is_empty():
		return
	%LatestDeploymentTextEdit.text = "Getting latest deployment information..."
	config.set_security_auth0(DotEnv.get_k("HATHORA_DEVELOPER_TOKEN"))
	var deploymentApi = DeploymentV1Api.new(config)
	deploymentApi.get_deployments(HathoraProjectSettings.get_s("application_id"), _update_deployment_success, _update_deployment_error)
	
func _update_deployment_success(response):
	if (response && response.data && len(response.data) > 0):
		updated_deployment.emit(response.data[0])
		return
	if response:
		# We still emit empty data, this will be interpreted by other components as no latest deployment present
		updated_deployment.emit(response.data)

func _update_deployment_error(err):
	if err.response_code == 401:
		owner.reset_token()
	print("[HATHORA] " + str(err))
