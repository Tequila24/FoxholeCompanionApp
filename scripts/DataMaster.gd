extends Node


@export var _entities_path: String = ""


@export var _all_entities: Dictionary[String, GameEntity]


@export var _all_categories: Array[Category]
var all_categories: Array[Category]:
	get:
		return _all_categories



func _ready() -> void:
	_all_entities.assign(Utils.load_resources_to_dict_recursive(
		_entities_path, 
		func(_res: Variant, _file_name: String):
			return _file_name.get_basename()
	))


func get_entities_in_category(category: Category) -> Array[GameEntity]:
	return _all_entities.values().filter(
		func(entity: GameEntity):
			return entity.category == category
	)
