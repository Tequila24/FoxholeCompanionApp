class_name DamageCalculationResult
extends Resource



class Counter:
	var ammo_type_id: String = ""
	var shots_count: int = 0


class StatStringPair:
	func _init(_title: String, _value: String) -> void:
		title = _title
		value = _value

	var title: String = ""
	var value: String = ""


var is_valid: bool = false
var counters: Array[Counter]
var stats: Array[StatStringPair]



func add_stats_line(_title: String, _value: String):
	stats.append(DamageCalculationResult.StatStringPair.new(_title, _value))