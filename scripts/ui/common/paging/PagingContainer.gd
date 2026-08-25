class_name PagingContainer
extends MarginContainer



@export var pages: Array[PagingButton]


var _selected_idx: int = 0



func _ready() -> void:
	_update_view()


func _update_view():
	pass