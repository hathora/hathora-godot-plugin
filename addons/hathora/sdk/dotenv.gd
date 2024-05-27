extends Object

const EXPECTED_KEYS = [
	"HATHORA_DEVELOPER_TOKEN",
]
const BASE_SECTION = "base"
const CONFIG_PATH_EDITOR = "res://.hathora/config"

static func get_first_existing_file(paths: Array[String]) -> String:
	for p in paths:
		if FileAccess.file_exists(p):
			return p
	return ""

static func config():
	var config_path_server_build = OS.get_executable_path().get_base_dir().path_join("hathora_config")
	var config_path = get_first_existing_file([CONFIG_PATH_EDITOR, config_path_server_build])
	
	if config_path.is_empty():
		print("[HATHORA] Hathora config not found " + CONFIG_PATH_EDITOR + " or at " + config_path_server_build + ". You will not have access to API endpoints requiring a devToken.")
		if not Engine.is_editor_hint():
			return
		print("Creating a new config at " + CONFIG_PATH_EDITOR)
		DirAccess.make_dir_absolute("res://.hathora")
		var config = ConfigFile.new()
		var err = config.save(CONFIG_PATH_EDITOR)
		if err:
			print("[HATHORA] Error creating new config file at " + CONFIG_PATH_EDITOR)
			return
			
	config_path = get_first_existing_file([CONFIG_PATH_EDITOR, config_path_server_build])
	var config = ConfigFile.new()
	var err = config.load(config_path)
	
	if err:
		print("[HATHORA] Error loading config file")
		return
		
	print("[HATHORA] Found Hathora config file at " + config_path)
		
static func add(key, value):
	var config_path_server_build = OS.get_executable_path().get_base_dir().path_join("hathora_config")
	var config_path = get_first_existing_file([CONFIG_PATH_EDITOR, config_path_server_build])
	var config = ConfigFile.new()
	var err = config.load(config_path)
	config.set_value(BASE_SECTION, key, value)
	config.save(config_path)

static func get_k(key) -> String:
	var config_path_server_build = OS.get_executable_path().get_base_dir().path_join("hathora_config")
	var config_path = get_first_existing_file([CONFIG_PATH_EDITOR, config_path_server_build])
	var config = ConfigFile.new()
	var err = config.load(config_path)
	var v = config.get_value(BASE_SECTION, key, "")
	return v
