class_name DamageCalculatorWindow
extends MarginContainer



@export var _attacker_entity_view: EntityView
@export var _target_entity_view: EntityView
@export var _switch_button: Button
@export var _invalid_icon: Control

@export var _counters_views: Array[CounterView]

@export var _stats_holder: StatsLinesHolder

# @export var _line_base_damage: DamageCalculatorStatLineView
# @export var _line_target_health: DamageCalculatorStatLineView
# @export var _line_time_to_kill: DamageCalculatorStatLineView



func _ready() -> void:
	DamageCalcWrapper.recalculated.connect(_on_new_calculation)
	_switch_button.pressed.connect(_switch_entities)

	_attacker_entity_view.pressed.connect(
		func(): 
			UI.entity_selection_window.show_window()
			# UI.entity_selection_window.set_visible_entity_type(GameEntity.COMPONENT_FILTER.ATTACKING)
			UI.entity_selection_window.entity_selected.connect(
				func(new_entity: GameEntity):
					_attacker_entity_view.set_visual(new_entity)
					DamageCalcWrapper.attacker_entity = new_entity
					DamageCalcWrapper.recalculate(),
					Object.CONNECT_ONE_SHOT
			)
	)

	_target_entity_view.pressed.connect(
		func(): 
			UI.entity_selection_window.show_window()
			# UI.entity_selection_window.set_visible_entity_type(GameEntity.COMPONENT_FILTER.ATTACKING)
			UI.entity_selection_window.entity_selected.connect(
				func(new_entity: GameEntity):
					_target_entity_view.set_visual(new_entity)
					DamageCalcWrapper.target_entity = new_entity
					DamageCalcWrapper.recalculate(),
					Object.CONNECT_ONE_SHOT
			)
	)

	# _target_entity_view.pressed.connect(
	# 	func(): 
	# 		UI.entity_selection_window.show_window()
	# 		UI.entity_selection_window.set_visible_entity_type(GameEntity.COMPONENT_FILTER.DAMAGEABLE)
	# 		UI.entity_selection_window.entity_selected.connect(
	# 			func(new_entity: GameEntity):
	# 				_target_entity_view.set_visual(new_entity)
	# 				DamageCalcWrapper.target_entity = new_entity
	# 				DamageCalcWrapper.recalculate(),
	# 				Object.CONNECT_ONE_SHOT
	# 		)
	# )

	_on_new_calculation(DamageCalculationResult.new())


func _switch_entities():
	var temp_attacker_entity = DamageCalcWrapper.attacker_entity
	DamageCalcWrapper.attacker_entity = DamageCalcWrapper.target_entity
	DamageCalcWrapper.target_entity = temp_attacker_entity

	_update_visual()

	DamageCalcWrapper.recalculate()


func _update_visual():
	_attacker_entity_view.set_visual(DamageCalcWrapper.attacker_entity)
	_target_entity_view.set_visual(DamageCalcWrapper.target_entity)


func _on_new_calculation(result: DamageCalculationResult) -> void:
	
	if (not result.is_valid):
		_invalid_icon.visible = true
		for view in _counters_views:
			view.visible = false
		
	else:
		for view in _counters_views:
			view.visible = false

		var idx: int = 0
		# for gun_counter in result.guns_counters:
		# 	_invalid_icon.visible = false
		# 	_counters_views.get(idx).visible = true
		# 	_counters_views.get(idx).counter_label.text = str(gun_counter.shot_count)
		# 	# if (DamageCalcWrapper.attacker_entity is ItemEntity):
		# 		# _counters_views.get(idx).icon_holder.visible = false
		# 	# else:
		# 	_counters_views.get(idx).icon_holder.visible = true
		# 	_counters_views.get(idx).icon_view.texture = gun_counter.ammo_type.icon

		# 	idx += 1

	_update_data_lines(result)


func _update_data_lines(result: DamageCalculationResult) -> void:
	_stats_holder.clear()

	if (not result.is_valid):
		return

	for pair in result.stats:
		_stats_holder.add_line(pair.title, pair.value)
