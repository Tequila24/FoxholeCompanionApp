class_name StatsLinesHolder
extends MarginContainer



@export var _line_prefab: PackedScene

@export var _lines_holder: Control


func clear():
	Utils.clear_children(_lines_holder)


func add_line(title: String, value: String):
	var new_line = _line_prefab.instantiate() as DamageCalculatorStatLineView
	new_line.title_label.text = title
	new_line.value_label.text = value
	_lines_holder.add_child(new_line)
