class_name DamageCalculatorWindow
extends MarginContainer



@export var _attacker_entity_view: EntityView
@export var _target_entity_view: EntityView
@export var _switch_button: Button
@export var _invalid_icon: Control
@export var _counter_label: Label

@export var _line_base_damage: DamageCalculatorStatLineView
@export var _line_target_health: DamageCalculatorStatLineView
@export var _line_target_resistance: DamageCalculatorStatLineView
@export var _line_time_to_kill: DamageCalculatorStatLineView



func _ready() -> void:
	DamageCalcWrapper.updated.connect(_update)
	_switch_button.pressed.connect(_switch_entities)

	_attacker_entity_view.pressed.connect(
		func(): 
			var window = EntitySelectionWindow.open_window()
			window.entity_selected.connect(
				func(new_entity: GameEntity):
					_attacker_entity_view.set_visual(new_entity)
					DamageCalcWrapper.set_attacker_entity(new_entity)
			)
	)

	_target_entity_view.pressed.connect(
		func(): 
			var window = EntitySelectionWindow.open_window()
			window.entity_selected.connect(
				func(new_entity: GameEntity):
					_target_entity_view.set_visual(new_entity)
					DamageCalcWrapper.set_target_entity(new_entity)
			)
	)

	_update()


func _switch_entities():
	# print(DamageCalcWrapper.attacker_entity)
	# print(DamageCalcWrapper.target_entity)

	var temp_attacker_entity = DamageCalcWrapper.attacker_entity
	DamageCalcWrapper.set_attacker_entity(DamageCalcWrapper.target_entity)
	_attacker_entity_view.set_visual(DamageCalcWrapper.attacker_entity)
	DamageCalcWrapper.set_target_entity(temp_attacker_entity)
	_target_entity_view.set_visual(DamageCalcWrapper.target_entity)

	# print(DamageCalcWrapper.attacker_entity)
	# print(DamageCalcWrapper.target_entity)

	_update()


func _update() -> void:
	DamageCalcWrapper.recalculate()

	var result = DamageCalcWrapper.current_result
	if (not result.is_valid):
		_invalid_icon.visible = true
		_counter_label.visible = false
	else:
		_invalid_icon.visible = false
		_counter_label.visible = true
		_counter_label.text = str(result.count)

	_update_data_lines()


func _update_data_lines() -> void:
	var current_result = DamageCalcWrapper.current_result
	if (not current_result || not current_result.is_valid):
		_line_base_damage.clear()
		_line_target_health.clear()
		_line_target_resistance.clear()
		_line_time_to_kill.clear()
		return
	
	_line_base_damage.set_value(current_result.base_damage)
	_line_target_health.set_value(current_result.target_health)
	_line_target_resistance.set_value(-current_result.target_resistance)
	_line_target_resistance.set_measurement_visible(true)
	if (current_result.time_to_kill > 0):
		_line_time_to_kill.set_value(current_result.time_to_kill)
		_line_time_to_kill.set_measurement_visible(true)
	else:
		_line_time_to_kill.clear()
