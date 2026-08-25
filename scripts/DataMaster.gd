extends Node


const DEBUG = true


const _VEHICLES_DATA_PATH: String  = "res://data/Foxhole Vehicles.json"
const _ITEMS_DATA_PATH: String = "res://data/Foxhole Items.json"
const _ARMAMENT_DATA_PATH: String = "res://data/Foxhole Armament.json"



var _vehicles_data: Array[Variant]
var _items_data: Array[Variant]
var _armament_data: Array[Variant]


var _all_vehicles: Dictionary[String, VehicleEntity] = {}
var _all_items: Dictionary[String, ItemEntity] = {}



func _ready() -> void:
	_load_data()


func _load_data():
	var vehicles_file_str = FileAccess.get_file_as_string(_VEHICLES_DATA_PATH)
	var armaments_file_str = FileAccess.get_file_as_string(_ARMAMENT_DATA_PATH)
	var items_file_str = FileAccess.get_file_as_string(_ITEMS_DATA_PATH)
	
	_vehicles_data = JSON.parse_string(vehicles_file_str)
	_armament_data = JSON.parse_string(armaments_file_str)
	_items_data = JSON.parse_string(items_file_str)

	_load_vehicles()
	_load_items()
	

func _load_vehicles():
	for vehicle_entry: Dictionary in _vehicles_data:
		var new_vehicle: VehicleEntity = VehicleEntity.new()
		if (vehicle_entry.get("codename") == null):
			continue
		new_vehicle.id = vehicle_entry.get("codename", "")
		new_vehicle.name = vehicle_entry.get("name", "")
		new_vehicle.image_name = vehicle_entry.get("image", "")
		var faction_name = vehicle_entry.get("faction")
		if (faction_name == "War"):
			new_vehicle.faction = Enums.Faction.WARDEN
		elif (faction_name == "Col"):
			new_vehicle.faction = Enums.Faction.COLONIAL
		else:
			new_vehicle.faction = Enums.Faction.NEUTRAL


		# Vitals
		var vitals: ComponentVitals = ComponentVitals.new()
		vitals.max_health = (vehicle_entry["vehicle hp"]) if (vehicle_entry["vehicle hp"] != null) else (0.0)
		vitals.disable_threshold = (vehicle_entry["disable"] * 0.01) if (vehicle_entry["disable"] != null) else (0.0)
		vitals.resistance_id = vehicle_entry["armour type"] if (vehicle_entry["armour type"] != null) else ("LightVehicle")
		vitals.max_armor = (vehicle_entry["armour hp"]) if (vehicle_entry["armour hp"] != null) else (0.0)
		new_vehicle.add_component(vitals)

		# Armament
		var vic_arm_entries: Array = _armament_data.filter(
			func(arm_entry: Dictionary):
				return arm_entry.get("parent_name", "") == new_vehicle.name
		)
		
		for arm_entry: Dictionary in vic_arm_entries:
			var used_ammo_ids: Array[String] = []
			for i in range(5):
				var ammo_id: String = arm_entry.get("AmmoName%d" % i, "")
				if (not ammo_id.is_empty()):
					used_ammo_ids.append(ammo_id)

			if (used_ammo_ids.is_empty()):
				print("No ammo used, skipping")
				continue

			var new_gun: ComponentGun = ComponentGun.new()
			new_gun.ammo_used_ids.assign(used_ammo_ids)
			new_gun.magazine_size = arm_entry.get("MagazineSize", 1)
			new_gun.cooldown_duration_s = arm_entry.get("FiringTime", 0)
			new_gun.reload_duration_s = arm_entry.get("ReloadTime", 0)
			new_gun.damage_modifier = 1.0 + float(arm_entry.get("VelocityMod", 0.0))

			new_vehicle.add_component(new_gun)

		
		_all_vehicles[new_vehicle.id] = new_vehicle


func _load_items():
	for item_entry: Dictionary in _items_data:
		if (item_entry["codename"] == null):
			continue

		var new_item: ItemEntity = ItemEntity.new()
		new_item.id = item_entry["codename"]
		new_item.name = item_entry["name"]
		new_item.image_name = item_entry["image"]
		var faction_name = item_entry["faction"]
		if (faction_name == "War"):
			new_item.faction = Enums.Faction.WARDEN
		elif (faction_name == "Col"):
			new_item.faction = Enums.Faction.COLONIAL
		else:
			new_item.faction = Enums.Faction.NEUTRAL

		if (item_entry["damage"] != null):
			var new_damage_component: ComponentDamage = ComponentDamage.new()
			new_damage_component.raw_damage = item_entry["damage"]
			new_damage_component.damage_type_id = item_entry["damage type"]
			new_item.add_component(new_damage_component)

		_all_items[new_item.name] = new_item



func get_resistance_to_damage_type(tier_id: String, damage_type_id: String) -> float:
	return 0
	# var tier_column_id: String = _resistance_tier_id_enum_to_column_str.get(tier_id, "light_vehicle_damage_mitigation")
	# var resistances_for_tier_result: Array[Dictionary] = foxhole_db.select_rows("damageprofiles", "id == '%s'" % damage_type_id, ["%s" % tier_column_id])

	# return (resistances_for_tier_result.get(0)[tier_column_id] as float)



func get_all_vehicle_entities() -> Array[VehicleEntity]:
	return _all_vehicles.values()


func get_vehicle_entity(id: String) -> VehicleEntity:
	return _all_vehicles.get(id, VehicleEntity.new())


func get_item_entity(id: String) -> ItemEntity:
	var item: ItemEntity = ItemEntity.new()

	# var quiery_result = foxhole_db.select_rows("ammo", "id == '%s'" % id, ["name", "damage", "damage_type_display_name", "iconobject_path"])
	# if (quiery_result.is_empty()):
	# 	if (DEBUG): print("Error processing %s id!" % id)
	# 	return null

	# ammo_entity.id = id
	# ammo_entity.name = quiery_result.get(0).name
	# ammo_entity.icon_path = quiery_result.get(0).iconobject_path

	# var new_damage_component: ComponentDamage = ComponentDamage.new()
	# new_damage_component.raw_damage = quiery_result.get(0).damage
	# new_damage_component.damage_type_id = _damage_type_name_to_id.get(quiery_result.get(0).damage_type_display_name, "Light Kinetic")
	# ammo_entity.add_component(new_damage_component)

	# # print(quiery_result.get(0))
	# # print(quiery_result.get(0).name)
	# # print(quiery_result.get(0).damage)
	# # print(type_string(typeof(quiery_result.get(0))))

	return item


func _exit_tree() -> void:
	pass
