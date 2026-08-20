@tool
class_name AutoFitRichTextLabel
extends RichTextLabel



@export var max_font_size: int = 32:
	get:
		return max_font_size
	set(value):
		max_font_size = value
		_fit()

@export var min_font_size: int = 1


@export_multiline var fit_text: String:
	get:
		return text
	set(value):
		text = value
		_fit()



func _ready() -> void:
	fit_content = false
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF


func _fit() -> void:
	if not is_inside_tree():
		return

	var current_size: int = max_font_size
	_apply_size(current_size)
	
	while current_size > min_font_size and _is_overflowing():
		current_size -= 1
		_apply_size(current_size)


func _apply_size(new_size: int) -> void:
	add_theme_font_size_override("normal_font_size", new_size)
	add_theme_font_size_override("bold_font_size", new_size)
	add_theme_font_size_override("italics_font_size", new_size)
	add_theme_font_size_override("bold_italics_font_size", new_size)


func _is_overflowing() -> bool:
	var overflow_height = get_content_height() > self.size.y
	var overflow_width = get_content_width() > self.size.x
	return overflow_height || overflow_width