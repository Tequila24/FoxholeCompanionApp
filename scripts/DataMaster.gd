extends Node


const DEBUG = true


const _VEHICLES_DATA_PATH: String  = "res://data/Foxhole Vehicles.json"
const _ITEMS_DATA_PATH: String = "res://data/Foxhole Items.json"
const _ARMAMENT_DATA_PATH: String = "res://data/Foxhole Armament.json"
const _RESISTANCES_DATA_PATH: String = "res://data/DamageResistances.json"



# var _vehicles_data: Array[Variant]
# var _items_data: Array[Variant]
# var _armament_data: Array[Variant]


var _all_vehicles: Dictionary[String, VehicleEntity] = {}
var _all_items: Dictionary[String, ItemEntity] = {}
var _damage_type_resistances: Dictionary[String, Dictionary] = {
	# "LightVehicle" = {},
	# "Tier1Tank" = {},
	# "Tier2Tank" = {},
	# "Tier1Ship" = {},
	# "Tier2Ship" = {},
	# "Tier1LargeShip" = {},
	# "Tier1Aircraft" = {},
	# "Tier1Structure" = {},
	# "Tier2Structure" = {},
	# "Tier2BStructure" = {},
	# "Tier3Structure" = {},
	# "Tier3BStructure" = {},
	# "Tier1GarrisonHouse" = {},
	# "Tier2GarrisonHouse" = {},
	# "Tier3GarrisonHouse" = {},
	# "Trench" = {}
}



func _ready() -> void:
	_load_data()


func _load_data():
	_load_vehicles()
	_load_items()
	_load_resistances()
	

func _load_vehicles():
	var _vehicles_data = JSON.parse_string(FileAccess.get_file_as_string(_VEHICLES_DATA_PATH))
	var _armament_data = JSON.parse_string(FileAccess.get_file_as_string(_ARMAMENT_DATA_PATH))
	
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
				return arm_entry.get("parent name", "") == new_vehicle.name
		)
		
		for arm_entry: Dictionary in vic_arm_entries:
			var used_ammo_ids: Array[String] = []
			for i in range(1,5):
				var ammo_id: String = (arm_entry["AmmoName%d" % i]) if (arm_entry["AmmoName%d" % i] != null) else ("")
				if (not ammo_id.is_empty()):
					used_ammo_ids.append(ammo_id)

			if (used_ammo_ids.is_empty()):
				print("No ammo used, skipping")
				continue

			var new_gun: ComponentGun = ComponentGun.new()
			new_gun.ammo_used_ids.assign(used_ammo_ids)
			new_gun.magazine_size = (arm_entry["MagazineSize"]) if (arm_entry["MagazineSize"] != null) else (1)
			new_gun.cooldown_duration_s = (arm_entry["FiringTime"]) if (arm_entry["FiringTime"] != null) else (0)
			new_gun.reload_duration_s = (arm_entry["ReloadTime"]) if (arm_entry["ReloadTime"] != null) else (0)
			new_gun.fire_rate = (arm_entry["FireRate"]) if (arm_entry["FireRate"] != null) else (0)
			new_gun.damage_modifier = 1.0 + float(((arm_entry["VelocityMod"]) if (arm_entry["VelocityMod"] != null) else (0)) * 0.01)

			# print("%s adding gun component" % new_vehicle.name)
			new_vehicle.add_component(new_gun)

		
		_all_vehicles[new_vehicle.id] = new_vehicle


func _load_items():
	var _items_data = JSON.parse_string(FileAccess.get_file_as_string(_ITEMS_DATA_PATH))

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


func _load_resistances():
	var _resistances_data = JSON.parse_string(FileAccess.get_file_as_string(_RESISTANCES_DATA_PATH))

	for damage_type_data: Dictionary in _resistances_data:
		_damage_type_resistances[damage_type_data["name"]] = {}
		_damage_type_resistances[damage_type_data["name"]]["image"] = damage_type_data["image"]
		
		_damage_type_resistances[damage_type_data["name"]]["LightVehicle"] = damage_type_data["LightVehicle"]
		_damage_type_resistances[damage_type_data["name"]]["Tier1Tank"] = damage_type_data["Tier1Tank"]
		_damage_type_resistances[damage_type_data["name"]]["Tier2Tank"] = damage_type_data["Tier2Tank"]
		_damage_type_resistances[damage_type_data["name"]]["Tier1Ship"] = damage_type_data["Tier1Ship"]
		_damage_type_resistances[damage_type_data["name"]]["Tier2Ship"] = damage_type_data["Tier2Ship"]
		_damage_type_resistances[damage_type_data["name"]]["Tier1LargeShip"] = damage_type_data["Tier1LargeShip"]
		_damage_type_resistances[damage_type_data["name"]]["Tier1Aircraft"] = damage_type_data["Tier1Aircraft"]
		_damage_type_resistances[damage_type_data["name"]]["Tier1Structure"] = damage_type_data["Tier1Structure"]
		_damage_type_resistances[damage_type_data["name"]]["Tier2Structure"] = damage_type_data["Tier2Structure"]
		_damage_type_resistances[damage_type_data["name"]]["Tier2BStructure"] = damage_type_data["Tier2BStructure"]
		_damage_type_resistances[damage_type_data["name"]]["Tier3Structure"] = damage_type_data["Tier3Structure"]
		_damage_type_resistances[damage_type_data["name"]]["Tier3BStructure"] = damage_type_data["Tier3BStructure"]
		_damage_type_resistances[damage_type_data["name"]]["Tier1GarrisonHouse"] = damage_type_data["Tier1GarrisonHouse"]
		_damage_type_resistances[damage_type_data["name"]]["Tier2GarrisonHouse"] = damage_type_data["Tier2GarrisonHouse"]
		_damage_type_resistances[damage_type_data["name"]]["Tier3GarrisonHouse"] = damage_type_data["Tier3GarrisonHouse"]
		_damage_type_resistances[damage_type_data["name"]]["Trench"] = damage_type_data["Trench"]


func get_damage_resistance(tier_id: String, damage_type_id: String) -> float:
	return _damage_type_resistances[damage_type_id][tier_id]
	# var tier_column_id: String = _resistance_tier_id_enum_to_column_str.get(tier_id, "light_vehicle_damage_mitigation")
	# var resistances_for_tier_result: Array[Dictionary] = foxhole_db.select_rows("damageprofiles", "id == '%s'" % damage_type_id, ["%s" % tier_column_id])

	# return (resistances_for_tier_result.get(0)[tier_column_id] as float)


func get_damage_resistance_as_string(tier_id: String, damage_type_id: String) -> String:
	return "[img width=1.2em]%s[/img]%s%%" % [("res://assets/textures/game_icons/ItemIcons/" + _damage_type_resistances[damage_type_id]["image"]), str(_damage_type_resistances[damage_type_id][tier_id] * 100)]



func get_all_vehicle_entities() -> Array[VehicleEntity]:
	return _all_vehicles.values()


func get_vehicle_entity(id: String) -> VehicleEntity:
	return _all_vehicles.get(id, VehicleEntity.new())


func get_item_entity(id: String) -> ItemEntity:
	return _all_items.get(id, ItemEntity.new())


func _exit_tree() -> void:
	pass
