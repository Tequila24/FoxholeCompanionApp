@tool
class_name AutoFitLabel
extends MarginContainer


@export var max_font_size: int = 32
@export var min_font_size: int = 1

@export var _label: RichTextLabel
@export var text: String:
	get:
		if (not _label):
			return ""
		else:
			return _label.text

	set(value):
		if (not _label):
			return
		_label.text = value
		_fit()

var _is_calculating: bool = false



func _ready() -> void:
	# Prevent the label from pushing the container bounds outward
	# _label.custom_minimum_size = Vector2.ZERO
	# _label.fit_content = false
	
	# resized.connect(_fit)
	_fit()


func _fit() -> void:
	if not is_inside_tree() or not _label or _is_calculating:
		return

	_is_calculating = true

	# Reset to max bounds on every resize or text change
	var current_size: int = max_font_size
	_apply_size(current_size)

	while current_size > min_font_size and _is_overflowing():
		current_size -= 1
		_apply_size(current_size)

	_is_calculating = false


func _is_overflowing() -> bool:
	var overflow_height = _label.get_content_height() > self.size.y
	# print(str(_label.get_content_height()) + " " + str(self.size.y))
	var overflow_width =_label.get_content_width() > self.size.x
	# print(str(_label.get_content_width()) + " " + str(self.size.y))
	# print(str(overflow_height) + " " + str(overflow_width))
	return overflow_height || overflow_width


func _apply_size(new_size: int) -> void:
	_label.add_theme_font_size_override("normal_font_size", new_size)
	_label.add_theme_font_size_override("bold_font_size", new_size)
	_label.add_theme_font_size_override("italics_font_size", new_size)
	_label.add_theme_font_size_override("bold_italics_font_size", new_size)
