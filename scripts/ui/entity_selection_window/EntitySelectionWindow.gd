class_name EntitySelectionWindow
extends MarginContainer


# const SELF_PREFAB: PackedScene = preload("res://scenes/ui/entity_selection_window/EntitySelectionWindow.tscn")

# # @export var _category_view: PackedScene
@export var _entity_view_prefab: PackedScene
# # @export var _categories_holder: Control
@export var _views_holder: Control
@export var _close_button: Button



# var _types_visible: GameEntity.COMPONENT_FILTER = GameEntity.COMPONENT_FILTER.ANY
# @export var _filter_warden: Button
# @export var _filter_colonial: Button
# @export var _filter_tanks: Button
# @export var _filter_pushguns: Button
# @export var _filter_cars: Button
# @export var _filter_structures: Button


signal entity_selected(new_entity: GameEntity)



# # static func open_window() -> EntitySelectionWindow:
# # 	var new_window = SELF_PREFAB.instantiate() as EntitySelectionWindow
# # 	UI.add_child(new_window)
# # 	return new_window


func _ready() -> void:
	hide_window()
	_close_button.pressed.connect(hide_window)
	_fill_entities()
	
# 	_filter_warden.toggled.connect(func(_toggled): _update_filters())
# 	_filter_colonial.toggled.connect(func(_toggled): _update_filters())
# 	_filter_tanks.toggled.connect(func(_toggled): _update_filters())
# 	_filter_pushguns.toggled.connect(func(_toggled): _update_filters())
# 	_filter_cars.toggled.connect(func(_toggled): _update_filters())
# 	_filter_structures.toggled.connect(func(_toggled): _update_filters())


# func set_visible_entity_type(type: GameEntity.COMPONENT_FILTER):
# 	_types_visible = type
# 	_update_filters()


func _fill_entities():
	var all_vehicle_entities: Array[VehicleEntity] = DataMaster.get_all_vehicle_entities()

	for entity in all_vehicle_entities:
		# var vitals_component: ComponentVitals = entity.get_component_of_type(ComponentVitals)
		# print("Name: %s" % [entity.name])
		# print("Icon path: %s" % [entity.icon_path])
		# if (vitals_component):
			# print("\t Health: %d" % vitals_component.max_health)
			# print("\t Disabled at: %d%%" % int((1.0 - vitals_component.disable_threshold) * 100))

		var new_view: EntityView = _entity_view_prefab.instantiate() as EntityView
		new_view.set_visual(entity)
		new_view.pressed.connect(func():
			_on_entity_view_tap(new_view)
		)
		_views_holder.add_child(new_view)

		# 	all_entities.sort_custom(func(a: GameEntity, b: GameEntity): return a.name < b.name)

		# 	for entity in all_entities:
		# 		var new_view = _entity_view_prefab.instantiate() as EntityView
		# 		new_view.set_visual(entity)
		# 		_views_holder.add_child(new_view)
		# 		new_view.pressed.connect(
		# 			func(): 
		# 				entity_selected.emit(entity)
		# 				hide_window()
		# 		)



func _on_entity_view_tap(view: EntityView):
	entity_selected.emit(view.attached_entity)
	hide_window()

# func _update_filters():
# 	for entity_view in (_views_holder.get_children() as Array[EntityView]):
# 		entity_view.visible = _entity_filter(entity_view.attached_entity)


# func _entity_filter(entity: GameEntity) -> bool:
# 	# print(entity.name)
# 	var result = false

# 	if (entity.has_component(AttackComponent) && (_types_visible & GameEntity.COMPONENT_FILTER.ATTACKING)):
# 		result = true

# 	if (entity.has_component(VitalsComponent) && (_types_visible & GameEntity.COMPONENT_FILTER.DAMAGEABLE)):
# 		result = true
	
# 	if ((entity.faction == DataMaster.faction_warden) && !_filter_warden.button_pressed):
# 		result = false

# 	if ((entity.faction == DataMaster.faction_colonial) && !_filter_colonial.button_pressed):
# 		result = false

# 	if (entity is VehicleEntity):
# 		var vehicle_entity: VehicleEntity = entity as VehicleEntity
# 		if ((vehicle_entity.type == VehicleEntity.VEHICLE_TYPE.TANK) && !_filter_tanks.button_pressed):
# 			result = false

# 		if ((vehicle_entity.type == VehicleEntity.VEHICLE_TYPE.PUSHGUN) && !_filter_pushguns.button_pressed):
# 			result = false

# 		if ((vehicle_entity.type == VehicleEntity.VEHICLE_TYPE.CAR) && !_filter_cars.button_pressed):
# 			result = false
	
# 	if ((entity is StructureEntity) && !_filter_structures.button_pressed):
# 		result = false

# 	return result


# # func _create_categories() -> void:
# # 	for category in DataMaster.all_categories:
# # 		var new_catergory_view = _category_view.instantiate() as EntityCategoryView
# # 		_categories_holder.add_child(new_catergory_view)
# # 		new_catergory_view.set_category(category)
# # 		new_catergory_view.entity_selected.connect(
# # 			func(new_entity: GameEntity): 
# # 				entity_selected.emit(new_entity)
# # 				close_window()
# # 		)


func show_window() -> void:
	self.visible = true


func hide_window() -> void:
	self.visible = false


func close_window() -> void:
	hide_window()
	queue_free()
