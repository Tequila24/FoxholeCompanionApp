class_name BottomButton
extends MarginContainer


const ANIM_DURATION = 0.05

signal pressed()

@export var _button: Button
@export var _bg_panel: Panel
@export var _content_parent: Control

var _toggle: bool

var _animation_tween: Tween


func _ready() -> void:
	_button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if (_toggle):
		return
		
	pressed.emit()


func toggle():
	_toggle = !_toggle

	_discard_current_animation()
	if _toggle:
		_animate_active()
	else:
		_animate_inactive()


func _discard_current_animation():
	if (_animation_tween == null):
		return

	_animation_tween.custom_step(999)
	_animation_tween.free()
	_animation_tween = null


func _animate_active():
	_animation_tween = self.create_tween()
	_animation_tween.tween_property(_bg_panel, "modulate:a", 1, ANIM_DURATION)
	_animation_tween.parallel().tween_property(_content_parent, "modulate", Color.hex(0x003c0bff), ANIM_DURATION)
	_animation_tween.parallel().tween_property(self, "offset_transform_position:y", -12, ANIM_DURATION)
	_animation_tween.tween_callback((func(): _animation_tween = null))


func _animate_inactive():
	_animation_tween = self.create_tween()
	_animation_tween.tween_property(_bg_panel, "modulate:a", 0, ANIM_DURATION)
	_animation_tween.parallel().tween_property(_content_parent, "modulate", Color.hex(0xffffffff), ANIM_DURATION)
	_animation_tween.parallel().tween_property(self, "offset_transform_position:y", 0, ANIM_DURATION)
	_animation_tween.tween_callback((func(): _animation_tween = null))
	
