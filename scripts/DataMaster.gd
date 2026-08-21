extends Node


const DEBUG = true


@export var foxhole_database_path: String  = ""
@export var _warden_faction_id: String
@export var _colonial_faction_id: String

var foxhole_db: SQLite = SQLite.new()



func _ready() -> void:

	foxhole_db.read_only = true
	foxhole_db.path = foxhole_database_path
	foxhole_db.open_db()

	# var result = foxhole_db.select_rows("vehicles", "name != 'NULL' AND faction_variant == 'EFactionId::Wardens'", ["name"])
	# for entry in result:
	# 	print(entry)

	# get_ammo_data("LightTankAmmo")


func get_all_vehicle_entities() -> Array[VehicleEntity]:
	var result: Array[VehicleEntity] = []

	var all_vics = foxhole_db.select_rows("vehicles", "name != 'NULL'", ["id", "name", "armour_type", "max_health", "minor_damage_percent", "iconobject_path"])
	
	for vehicle in all_vics:
		var new_entity: VehicleEntity = VehicleEntity.new()

		print(vehicle.name)

		new_entity.id = vehicle.id
		new_entity.name = vehicle.name
		new_entity.icon_path = (vehicle.iconobject_path as String).substr(24).left(-1) + "tga"

		var new_vitals_component: GameEntityComponentVitals = GameEntityComponentVitals.new()
		new_vitals_component.max_health = vehicle.max_health
		new_vitals_component.max_armor = 0
		new_vitals_component.disable_threshold = vehicle.minor_damage_percent if vehicle.minor_damage_percent < 1 else 1
		new_vitals_component.resistance_id = vehicle.armour_type
		new_entity.add_component(new_vitals_component)

		var all_gun_mounts = foxhole_db.select_rows("mounts", "parent == '%s'" % vehicle.id, ["ammo_name", "multi_ammo", "max_ammo", "damage_multiplier", "firing_durationdelaybetweenrefire", "reload_duration"])
		for gun_mount in all_gun_mounts:
			var new_attack_component: GameEntityComponentAttack = GameEntityComponentAttack.new()
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

			print("\t%s" % str(all_ammo_possible))

			new_attack_component.ammo_used_ids = all_ammo_possible
			new_attack_component.magazine_size = gun_mount.max_ammo
			new_attack_component.reload_duration_s = gun_mount.reload_duration
			new_attack_component.cooldown_duration_s = 0.25 if gun_mount.firing_durationdelaybetweenrefire == 0 else gun_mount.firing_durationdelaybetweenrefire
			new_attack_component.damage_modifier = gun_mount.damage_multiplier
			new_entity.add_component(new_attack_component)
		
		result.append(new_entity)

	return result


func get_ammo_data(id: String) -> AmmoEntity:
	var ammo_data: AmmoEntity = AmmoEntity.new()

	var quiery_result = foxhole_db.select_rows("ammo", "id == '%s'" % id, ["name", "damage"])
	if (quiery_result.is_empty()):
		if (DEBUG): print("Error processing %s id!" % id)

	print(quiery_result.get(0))
	print(quiery_result.get(0).name)
	print(quiery_result.get(0).damage)
	print(type_string(typeof(quiery_result.get(0))))

	return ammo_data


func _exit_tree() -> void:
	foxhole_db.close_db()
