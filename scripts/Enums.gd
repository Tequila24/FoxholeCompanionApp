class_name Enums


enum Faction {
	NEUTRAL = 0,
	WARDEN = 1 << 0,
	COLONIAL = 1 << 1,
	ANY = 0xFFFFFFFF
}

enum VehicleType {
	NONE = 0,
	TANK = 1 << 0,
	PUSHGUN = 1 << 1,
	CAR = 1 << 2,
	BOAT = 1 << 3,
	AIRCRAFT = 1 << 4,
	TRAIN = 1 << 5,
	ANY = 0xFFFFFFFF
}

enum EntityType {
	NONE = 0,
	VEHICLE = 1 << 0,
	STRUCTURE = 1 << 1,
	GUN = 1 << 2,
	ANY = 0xFFFFFFFF
}

static var AllDamageResistanceTiers: Array[String] = [
	"LightVehicle",
	"Tier1Tank",
	"Tier2Tank",
	"Tier1Ship",
	"Tier2Ship",
	"Tier1LargeShip",
	"Tier1Aircraft",
	"Tier1Structure",
	"Tier2Structure",
	"Tier2BStructure",
	"Tier3Structure",
	"Tier3BStructure",
	"Tier1GarrisonHouse",
	"Tier2GarrisonHouse",
	"Tier3GarrisonHouse",
	"Trench"
]