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


func get_all_entities() -> Array[GameEntity]:
	var result: Array[GameEntity] = []

	var all_vics = foxhole_db.select_rows("vehicles", "name != 'NULL'", ["id", "name", "max_health", "minor_damage_percent", "iconobject_path"])
	
	for vehicle in all_vics:
		var new_entity: GameEntity = GameEntity.new()

		new_entity.id = vehicle.id
		new_entity.name = vehicle.name
		new_entity.icon_path = (vehicle.iconobject_path as String).substr(24).left(-1) + "tga"

		var new_vitals_component: GameEntityComponentVitals = GameEntityComponentVitals.new()
		new_vitals_component.max_health = vehicle.max_health
		new_vitals_component.max_armor = 0
		new_vitals_component.disable_threshold = vehicle.minor_damage_percent if vehicle.minor_damage_percent < 1 else 1
		new_entity.add_component(new_vitals_component)
		
		result.append(new_entity)

	return result


func get_ammo_data(id: String) -> AmmoType:
	var ammo_data: AmmoType = AmmoType.new()

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
