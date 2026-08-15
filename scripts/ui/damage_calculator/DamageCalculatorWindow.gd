class_name DamageCalculatorWindow
extends MarginContainer



@export var _attacker_entity_view: EntityView
@export var _target_entity_view: EntityView
@export var _switch_button: Button
@export var _invalid_icon: Control

@export var _counters_views: Array[CounterView]

@export var _line_base_damage: DamageCalculatorStatLineView
@export var _line_target_health: DamageCalculatorStatLineView
@export var _line_time_to_kill: DamageCalculatorStatLineView



func _ready() -> void:
	DamageCalcWrapper.recalculated.connect(_update_visual)
	_switch_button.pressed.connect(_switch_entities)

	_attacker_entity_view.pressed.connect(
		func(): 
			var window = EntitySelectionWindow.open_window()
			window.entity_selected.connect(
				func(new_entity: GameEntity):
					_attacker_entity_view.set_visual(new_entity)
					DamageCalcWrapper.set_attacker_entity(new_entity)
					DamageCalcWrapper.recalculate()
			)
	)

	_target_entity_view.pressed.connect(
		func(): 
			var window = EntitySelectionWindow.open_window()
			window.entity_selected.connect(
				func(new_entity: GameEntity):
					_target_entity_view.set_visual(new_entity)
					DamageCalcWrapper.set_target_entity(new_entity)
					DamageCalcWrapper.recalculate()
			)
	)


func _switch_entities():
	var temp_attacker_entity = DamageCalcWrapper.attacker_entity
	DamageCalcWrapper.set_attacker_entity(DamageCalcWrapper.target_entity)
	_attacker_entity_view.set_visual(DamageCalcWrapper.attacker_entity)
	DamageCalcWrapper.set_target_entity(temp_attacker_entity)
	_target_entity_view.set_visual(DamageCalcWrapper.target_entity)

	DamageCalcWrapper.recalculate()


func _update_visual() -> void:
	var result = DamageCalcWrapper.current_result
	if (not result.is_valid):
		_invalid_icon.visible = true
		for view in _counters_views:
			view.visible = false
		
	else:
		_invalid_icon.visible = false
		_counters_views.get(0).visible = true
		_counters_views.get(0).counter_label.text = str(result.guns_results.get(0).shots_count)
		if (DamageCalcWrapper.attacker_entity is AmmoEntity):
			_counters_views.get(0).icon_holder.visible = false
		else:
			_counters_views.get(0).icon_holder.visible = true
			_counters_views.get(0).icon_view.texture = result.guns_results.get(0).ammo_type.icon

	_update_data_lines()


func _update_data_lines() -> void:
	var current_result = DamageCalcWrapper.current_result
	if (not current_result || not current_result.is_valid):
		_line_base_damage.clear()
		_line_target_health.clear()
		_line_time_to_kill.clear()
		return
	
	# _line_base_damage.set_value(current_result.base_damage)
	_line_target_health.set_value(current_result.target_health)
	if (current_result.time_to_kill > 0):
		_line_time_to_kill.set_value("%.2f" % current_result.time_to_kill)
		_line_time_to_kill.set_measurement_visible(true)
	else:
		_line_time_to_kill.clear()
