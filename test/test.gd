extends Control

const SERVER_PORT = 7531
const MAX_CONNECTIONS = 20

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	%CreateLobbyButton.pressed.connect(_create_lobby)
	%LoginButton.pressed.connect(_login_anonymous)
	%JoinLobbyButton.pressed.connect(_join_lobby_by_room_id)
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server on %s" % SERVER_PORT)
		start_server()
	

func _login_anonymous() -> void:
	var res = await HathoraSDK.auth_v1.login_anonymous().async()
	if res.is_error():
		print("Login error!", res)
		return
	%PlayerToken.text = res.get_data().token

func _join_lobby_by_room_id() -> void:
	print("Polling status of room ", %RoomID.text)
	var res = await HathoraSDK.room_v2.get_connection_info(%RoomID.text).async()
	if res.is_error():
		print(res)
		return
	var connection_info = res.get_data()
	if connection_info.status != Hathora.RoomStatus.ACTIVE:
		print("Room status: ", str(connection_info.status))
		_join_lobby_by_room_id()
		return
	_connect_to_room(connection_info)

func _connect_to_room(connection_info):
	var peer = ENetMultiplayerPeer.new()
	print("Connecting to %s with port %s" % [connection_info.exposedPort.host, connection_info.exposedPort.port])
	var error = peer.create_client(connection_info.exposedPort.host, connection_info.exposedPort.port)
	if error:
		print("Error in joining", error)
		return
	multiplayer.multiplayer_peer = peer
	await multiplayer.connected_to_server

func _create_lobby():
	var result = await HathoraSDK.lobby_v3.create(%PlayerToken.text, Hathora.Visibility.PUBLIC, Hathora.Region.FRANKFURT, {}).async()
	if result.is_error():
		print("Error creating lobby", result)
		return
	var lobby = result.get_data()
	print("Created lobby with roomId ", lobby.roomId)
	%RoomID.text = lobby.roomId
	
func list_active_lobbies():
	var res = await HathoraSDK.lobby_v3.list_active_public(%PlayerToken.text, Hathora.Region.FRANKFURT).async()
	print(res.get_data())
	
func leave_game():
	multiplayer.multiplayer_peer = null

func create_room() -> void:
	var result = await HathoraSDK.room_v2.create({}, Hathora.Region.CHICAGO).async()
	if result.is_error():
		print("Error creating room", result)
		return
	print(result)

func get_ping_endpoints() -> void:
	var result = await HathoraSDK.auth_v1.login_nickname("ciao").async()
	var _login = result.get_data()
	result = await HathoraSDK.discovery_v1.get_ping_service_endpoints().async()
	if result.is_error():
		print("Error getting ping endpoints", result)
		return
	print(result)
	
func _generate_random_short_code() -> String:
	var rng = RandomNumberGenerator.new()
	var random_match_name = rng.randi_range(100000, 999999)
	random_match_name = String.num_int64(random_match_name)
	return random_match_name
	
func get_processes() -> void:
	var result = await HathoraSDK.processes_v2.get_latest().async()
	if result.is_error():
		print("Error getting processes", result)
		return
	print(result)


func get_process_info(process_id: String) -> void:
	var result = await HathoraSDK.processes_v2.get_info(process_id).async()
	if result.is_error():
		print("Error getting process info", result)
		return
	print(result)

func _on_peer_connected(id):
	var label = Label.new()
	label.text = str(id)
	%ConnectedPeers.add_child(label)

func _on_peer_disconnected(id):
	print("Player disconnected")
	for label in %ConnectedPeers.get_children():
		if label.text == str(id):
			label.queue_free()

func _on_connected_ok():
	print("Connected!")
	
func _on_connected_fail():
	print("Connected fail")
	multiplayer.multiplayer_peer = null
		
func _on_server_disconnected():
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	for label in %ConnectedPeers.get_children():
		label.queue_free()

func start_server() -> void:
	print("Starting server...")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(SERVER_PORT, MAX_CONNECTIONS)
	if error:
		print("Error starting the server", error)
		return
	multiplayer.multiplayer_peer = peer
