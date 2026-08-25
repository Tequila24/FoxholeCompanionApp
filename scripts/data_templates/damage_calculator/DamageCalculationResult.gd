class_name DamageCalculationResult
extends Resource



class GunCalculationResult:
	func _init(_ammo_type: String, _shot_count: int):
		ammo_type = _ammo_type
		shot_count = _shot_count

	var ammo_type: String = ""
	var shot_count: int = 0


class StatStringPair:
	func _init(_title: String, _value: String) -> void:
		title = _title
		value = _value

	var title: String = ""
	var value: String = ""


var is_valid: bool = false
var guns_counters: Array[GunCalculationResult]
var stats: Array[StatStringPair]



func add_stats_line(_title: String, _value: String):
	stats.append(DamageCalculationResult.StatStringPair.new(_title, _value))