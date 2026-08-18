class_name EntitySelectionWindow
extends MarginContainer


const SELF_PREFAB: PackedScene = preload("res://scenes/ui/entity_selection_window/EntitySelectionWindow.tscn")

@export var _category_view: PackedScene
@export var _categories_holder: Control
@export var _close_button: Button


signal entity_selected(new_entity: GameEntity)



func _ready() -> void:
	_close_button.pressed.connect(close_window)
	_create_categories()


func _create_categories() -> void:
	for category in DataMaster.all_categories:
		var new_catergory_view = _category_view.instantiate() as EntityCategoryView
		_categories_holder.add_child(new_catergory_view)
		new_catergory_view.set_category(category)
		new_catergory_view.entity_selected.connect(
			func(new_entity: GameEntity): 
				entity_selected.emit(new_entity)
				close_window()
		)


static func open_window() -> EntitySelectionWindow:
	var new_window = SELF_PREFAB.instantiate() as EntitySelectionWindow
	UI.add_child(new_window)
	return new_window


func show_window() -> void:
	self.visible = true


func hide_window() -> void:
	self.visible = false


func close_window() -> void:
	hide_window()
	queue_free()
