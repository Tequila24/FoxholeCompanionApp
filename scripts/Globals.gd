extends Node


const ICONS_PATH: String = "res://assets/textures/game_icons/"
const ITEMS_SUBPATH: String = "ItemIcons/"


@export var _error_texture: Texture2D
var error_texture: Texture2D:
	get:
		return _error_texture