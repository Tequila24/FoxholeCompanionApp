extends Node


@export var _entities_path: String = ""


@export var _all_entities: Dictionary[String, GameEntity]


@export var _all_categories: Array[Category]
var all_categories: Array[Category]:
	get:
		return _all_categories


@export var _faction_warden: Faction
var faction_warden: Faction:
	get:
		return _faction_warden

@export var _faction_colonial: Faction
var faction_colonial: Faction:
	get:
		return _faction_colonial

@export var _faction_neutral: Faction
var faction_neutral: Faction:
	get:
		return _faction_neutral


func _ready() -> void:
	_all_entities.assign(Utils.load_resources_to_dict_recursive(
		_entities_path, 
		func(_res: Variant, _file_name: String):
			return _file_name.get_basename()
	))


func get_entities_in_category(category: Category) -> Array[GameEntity]:
	return _all_entities.values().filter(
		func(entity: GameEntity):
			# print("%s entity category, %s search category" % [entity.category.name, category.name])
			return entity.category == category
	)


func get_entities_by_filter(filter: Callable) -> Array[GameEntity]:
	return _all_entities.values().filter(filter)
