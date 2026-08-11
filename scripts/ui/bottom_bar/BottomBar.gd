class_name BottomBar
extends MarginContainer


signal selected_map()
signal selected_damage_calculator()


@export var _button_damage_calculator: BottomButton
@export var _button_map: BottomButton



func _ready() -> void:
	_button_damage_calculator.toggle()

	_button_map.pressed.connect(_on_map_selected)
	_button_damage_calculator.pressed.connect(_on_damage_calculator_selected)


func _on_map_selected():
	_button_map.toggle()
	_button_damage_calculator.toggle()
	selected_map.emit()


func _on_damage_calculator_selected():
	_button_map.toggle()
	_button_damage_calculator.toggle()
	selected_damage_calculator.emit()
