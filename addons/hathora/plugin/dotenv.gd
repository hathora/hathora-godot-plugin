extends Object

const EXPECTED_KEYS = [
	"HATHORA_DEVELOPER_TOKEN",
]
const BASE_SECTION = "base"
const CONFIG_PATH = "res://.hathora/config"
const BUILDS_PATH = "res://.hathora/builds"
const HathoraProjectSettings = preload("hathora_project_settings.gd")

static func config():
	HathoraProjectSettings.add_project_settings()
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	if err:
		print("[HATHORA] Hathora config not found at " + CONFIG_PATH+". Creating a new one.")
		
		var dir_err = DirAccess.make_dir_recursive_absolute(BUILDS_PATH)
		if dir_err:
			print("[HATHORA] Error creating " + BUILDS_PATH + " directory. Could not create Hathora config file.")
			return
		config.save(CONFIG_PATH)
		return
		
static func add(key, value):
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	if err != OK:
		print("[HATHORA] Error loading the config file")
	
	config.set_value(BASE_SECTION, key, value)
	err = config.save(CONFIG_PATH)
	
	if err != OK:
		print("[HATHORA] Error saving the config file")
	
	config()
	
static func get_k(key) -> String:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	var v = config.get_value(BASE_SECTION, key, "")
	return v
