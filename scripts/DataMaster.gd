extends Node


const DEBUG = true


@export var foxhole_database_path: String  = ""
@export var _warden_faction_id: String
@export var _colonial_faction_id: String

@export var _resistance_tier_id_enum_to_column_str: Dictionary[String, String] = {
	"" = 				"", # None
	"EArmourType::LightVehicle" = 			"light_vehicle_damage_mitigation",	# Unarmored
	"EArmourType::Tier1Tank" = 				"tier1tank_damage_mitigation", # Lightly Armoured
	"EArmourType::Tier2Tank" = 				"tier2tank_damage_mitigation", # Heavily Armoured
	"EArmourType::Tier1Ship" = 				"tier1ship_damage_mitigation", # Ship
	"EArmourType::Tier2Ship" = 				"tier2ship_damage_mitigation", # Armored Ship
	"EArmourType::Tier1LargeShip" = 		"tier1large_ship_damage_mitigation", # Large Ships
	"EArmourType::Tier1Aircraft" = 			"tier1aircraft_damage_mitigation", # Aircraft
	"EArmourType::Trench" = 				"trench_damage_mitigation", # Trench
	"EArmourType::Tier1Structure" = 		"tier1structure_damage_mitigation", # Structure Tier1
	"EArmourType::Tier2Structure" = 		"tier2structure_damage_mitigation", # Structure Tier2
	"EArmourType::Tier2BStructure" = 		"tier2bstructure_damage_mitigation", # Structure Tier2B
	"EArmourType::Tier3Structure" = 		"tier3structure_damage_mitigation", # Structure Tier3
	"EArmourType::Tier3BStructure" = 		"tier3bstructure_damage_mitigation", # Structure Tier3B
	"EArmourType::HeavyBuildSite" = 		"heavy_build_site_damage_mitigation", # ???
	"EArmourType::Tier1Garrison" = 			"tier1garrison_house_damage_mitigation", # GHouse T1
	"EArmourType::Tier2Garrison" = 			"tier2garrison_house_damage_mitigation", # GHouse T2
	"EArmourType::Tier3Garrison" = 			"tier3garrison_house_damage_mitigation", # GHouse T3
	"EArmourType::WorldStructureHusk" =		"world_structure_husk_damage_mitigation" # ???
}

@export var _damage_type_name_to_id: Dictionary[String, String] = {
	"Anti-Tank Explosive" = 	"AntiTankExplosive",
	"Anti-Tank Kinetic" = 		"AntiTankKinetic",
	"Armour Piercing" = 		"ArmourPiercing",
	"Demolition" =				"Demolition",
	"Explosive" = 				"Explosive",
	"Fire" = 					"Fire",
	"Heavy Kinetic" = 			"HeavyKinetic",
	"High Explosive" = 			"HighExplosive",
	"Incendiary" = 				"Incendiary",
	"Light Kinetic" = 			"LightKinetic",
	"Poisonous Gas" = 			"PoisonGas",
	"Shrapnel" = 				"Shrapnel",
	"Extinguishing" = 			"",
	"Flare" = 					"",
	"Smoke" = 					""
}

var foxhole_db: SQLite = SQLite.new()



func _ready() -> void:

	foxhole_db.read_only = true
	foxhole_db.path = foxhole_database_path
	foxhole_db.open_db()

	# var result = foxhole_db.select_rows("vehicles", "name != 'NULL' AND faction_variant == 'EFactionId::Wardens'", ["name"])
	# for entry in result:
	# 	print(entry)

	# get_ammo_entity("LightTankAmmo")


func get_resistance_to_damage_type(tier_id: String, damage_type_id: String) -> float:
	var tier_column_id: String = _resistance_tier_id_enum_to_column_str.get(tier_id, "light_vehicle_damage_mitigation")
	var resistances_for_tier_result: Array[Dictionary] = foxhole_db.select_rows("damageprofiles", "id == '%s'" % damage_type_id, ["%s" % tier_column_id])

	return (resistances_for_tier_result.get(0)[tier_column_id] as float)



func get_all_vehicle_entities() -> Array[VehicleEntity]:
	var result: Array[VehicleEntity] = []

	var all_vics = foxhole_db.select_rows("vehicles", "name != 'NULL'", ["id", "name", "armour_type", "max_health", "minor_damage_percent", "iconobject_path"])
	
	for vehicle in all_vics:
		var new_entity: VehicleEntity = VehicleEntity.new()

		# print(vehicle.name)

		new_entity.id = vehicle.id
		new_entity.name = vehicle.name
		new_entity.icon_path = (vehicle.iconobject_path as String).substr(24).left(-1) + "tga"

		var new_vitals_component: ComponentVitals = ComponentVitals.new()
		new_vitals_component.max_health = vehicle.max_health
		new_vitals_component.max_armor = 0
		new_vitals_component.disable_threshold = vehicle.minor_damage_percent if vehicle.minor_damage_percent < 1 else 1
		new_vitals_component.resistance_id = vehicle.armour_type
		new_entity.add_component(new_vitals_component)

		var all_vehicle_additional_seats = foxhole_db.select_rows("mounts_seats", "parent == '%s'" % vehicle.id, ["mount"])
		for seat in all_vehicle_additional_seats:
			var all_gun_mounts = foxhole_db.select_rows("mounts", "id == '%s'" % seat.mount, ["ammo_name", "multi_ammo", "max_ammo", "damage_multiplier", "firing_durationdelaybetweenrefire", "reload_duration"])

			for gun_mount in all_gun_mounts:
				var new_attack_component: ComponentGun = ComponentGun.new()
				var all_ammo_possible: Array[String] = []
				if (gun_mount.ammo_name):
					all_ammo_possible.append(gun_mount.ammo_name)
				if (gun_mount.multi_ammo != null && not gun_mount.multi_ammo.is_empty()):
					gun_mount.multi_ammo = gun_mount.multi_ammo.substr(1, gun_mount.multi_ammo.length()-2)
					for ammo_str in gun_mount.multi_ammo.rsplit(", ", true, 0):
						ammo_str = ammo_str.substr(1, ammo_str.length()-2)
						all_ammo_possible.append(ammo_str)

				if all_ammo_possible.is_empty():
					continue

				# print("\t%s" % str(all_ammo_possible))

				new_attack_component.ammo_used_ids = all_ammo_possible
				new_attack_component.magazine_size = gun_mount.max_ammo
				new_attack_component.reload_duration_s = gun_mount.reload_duration
				new_attack_component.cooldown_duration_s = 0.25 if gun_mount.firing_durationdelaybetweenrefire == 0 else gun_mount.firing_durationdelaybetweenrefire
				new_attack_component.damage_modifier = gun_mount.damage_multiplier
				new_entity.add_component(new_attack_component)
		
		result.append(new_entity)

	return result


func get_ammo_entity(id: String) -> ItemEntity:
	var ammo_entity: ItemEntity = ItemEntity.new()

	var quiery_result = foxhole_db.select_rows("ammo", "id == '%s'" % id, ["name", "damage", "damage_type_display_name", "iconobject_path"])
	if (quiery_result.is_empty()):
		if (DEBUG): print("Error processing %s id!" % id)
		return null

	ammo_entity.id = id
	ammo_entity.name = quiery_result.get(0).name
	ammo_entity.icon_path = quiery_result.get(0).iconobject_path

	var new_damage_component: ComponentDamage = ComponentDamage.new()
	new_damage_component.raw_damage = quiery_result.get(0).damage
	new_damage_component.damage_type_id = _damage_type_name_to_id.get(quiery_result.get(0).damage_type_display_name, "Light Kinetic")
	ammo_entity.add_component(new_damage_component)

	# print(quiery_result.get(0))
	# print(quiery_result.get(0).name)
	# print(quiery_result.get(0).damage)
	# print(type_string(typeof(quiery_result.get(0))))

	return ammo_entity


func _exit_tree() -> void:
	foxhole_db.close_db()
