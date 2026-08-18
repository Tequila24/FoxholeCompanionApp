class_name EntityCategoryView
extends Control



@export var _category_label: Label
@export var _entity_view_prefab: PackedScene
@export var _entities_views_holder: Container

var _category: Category
signal entity_selected(new_entity: GameEntity)



func _ready() -> void:
	pass


func set_category(new_category: Category):
	_category = new_category
	_update_view()
	

func _update_view() -> void:
	if (_category == null):
		return

	_category_label.text = _category.name

	_fill_entities()


func _fill_entities() -> void:
	for entity in DataMaster.get_entities_in_category(_category):
		var new_view = _entity_view_prefab.instantiate() as EntityView
		new_view.set_visual(entity)
		_entities_views_holder.add_child(new_view)
		new_view.pressed.connect(func(): entity_selected.emit(entity))
