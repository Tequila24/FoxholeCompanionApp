class_name DamageCalculatorStatLineView
extends Control


@export var value_label: Label
@export var measurement_label: Label


func clear():
	value_label.visible = false
	set_measurement_visible(false)


func set_value(value: Variant):
	value_label.visible = true
	
	if (value is int || value is float):
		value_label.text = str(value)

	if (value is String):
		value_label.text = value


func set_measurement_visible(_visible: bool):
	measurement_label.visible = _visible