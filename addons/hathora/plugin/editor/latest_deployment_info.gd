@tool
extends TextEdit

var ee_counter = 0

func _ready() -> void:
	%LatestDeploymentGetter.updated_deployment.connect(_on_updated_deployment)

func _on_updated_deployment(data) -> void:
	if not "buildId" in data:
		text = "Latest deployment not found. It's probably the first time you are deploying this application."
		return
	text = "appId: " + data.appId + "\n"
	text += "createdAt: " + data.createdAt + "\n"
	text += "deployment: " + str(data.deploymentId) + "\n"
	text += "plan: " + str(data.planName) + "\n"
	text += "roomsPerProcess: " + str(data.roomsPerProcess) + "\n"
	text += "transport: " + str(data.defaultContainerPort.transportType) + "\n"
	text += "port: " + str(data.defaultContainerPort.port) + "\n"


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		ee_counter += 1
		print(ee_counter)
		if ee_counter >= 10:
			%ASCIIArt.show_art()
			ee_counter = 0
