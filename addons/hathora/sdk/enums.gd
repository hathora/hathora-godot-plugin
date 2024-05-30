extends RefCounted

class_name Hathora

enum Region {
	SEATTLE,
	WASHINGTON_DC,
	CHICAGO,
	LONDON,
	FRANKFURT,
	MUMBAI,
	SINGAPORE,
	SYDNEY,
	TOKYO,
	SAO_PAULO,
	LOS_ANGELES,
	DALLAS, ##Howdy, Godot developer
	}

enum TransportType { ## Transport type specifies the underlying communication protocol to the exposed port.
	UDP, 
	TCP, 
	TLS }

enum Plan { ## A plan defines how much CPU and memory is required to run an instance of your game server.
	TINY, ## shared core, 1gb memory
	SMALL, ## 1 core, 2gb memory
	MEDIUM, ## 2 core, 4gb memory
	LARGE ## 4 core, 8gb memory
	}

enum Visibility { ## Types of lobbies a player can create.
PRIVATE, ## The player who created the room must share the roomId with their friends
PUBLIC, ## Visible in the public lobby list, anyone can join
LOCAL, ## For testing with a server running locally
}

enum ProcessStatus { STARTING, RUNNING, DRAINING, STOPPING, STOPPED, FAILED }

enum RoomStatus { ## The allocation status of a room.
	SCHEDULING, 
	ACTIVE, 
	SUSPENDED, 
	DESTROYED }

const ROOM_STATUSES = {
	RoomStatus.SCHEDULING: "scheduling",
	RoomStatus.ACTIVE: "active",
	RoomStatus.SUSPENDED: "suspended",
	RoomStatus.DESTROYED: "destroyed"
}

const PROCESS_STATUSES = {
	ProcessStatus.STARTING: "starting",
	ProcessStatus.RUNNING: "running",
	ProcessStatus.DRAINING: "draining",
	ProcessStatus.STOPPING: "stopping",
	ProcessStatus.STOPPED: "stopped",
	ProcessStatus.FAILED: "failed",
}

const REGION_NAMES = {
	Region.SEATTLE: "Seattle",
	Region.WASHINGTON_DC: "Washington_DC",
	Region.CHICAGO: "Chicago",
	Region.LONDON: "London",
	Region.FRANKFURT: "Frankfurt",
	Region.MUMBAI: "Mumbai",
	Region.SINGAPORE: "Singapore",
	Region.SYDNEY: "Sydney",
	Region.TOKYO: "Tokyo",
	Region.SAO_PAULO: "Sao_Paulo",
	Region.LOS_ANGELES: "Los_Angeles",
	Region.DALLAS: "Dallas"
}

const TRANSPORT_TYPES = {
  TransportType.UDP: "udp",
  TransportType.TCP: "tcp",
  TransportType.TLS: "tls",
}

const PLANS = {
  Plan.TINY: "tiny",
  Plan.SMALL: "small",
  Plan.MEDIUM: "medium",
  Plan.LARGE: "large",
}

const VISIBILITY = {
	Visibility.PRIVATE: "private",
	Visibility.PUBLIC: "public",
	Visibility.LOCAL: "local",
}


