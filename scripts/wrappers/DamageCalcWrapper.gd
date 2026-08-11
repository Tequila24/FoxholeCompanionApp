extends Node


signal updated()

@export var _attacker_entity: GameEntity
@export var attacker_entity: GameEntity:
	get:
		return _attacker_entity

@export var _target_entity: GameEntity
@export var target_entity: GameEntity:
	get:
		return _target_entity

class CalcResult:
	var is_valid: bool = true
	var count: int = 0
	var base_damage: int = 0
	var target_health: int = 0
	var target_resistance: int = 0
	var time_to_kill: float = 0


var _current_result: CalcResult = CalcResult.new()
var current_result: CalcResult:
	get:
		return _current_result



func _ready() -> void:
	pass


func set_attacker_entity(new_entity: GameEntity): 
	_attacker_entity = new_entity
	updated.emit()


func set_target_entity(new_entity: GameEntity):
	_target_entity = new_entity
	updated.emit()


func get_target_health_points() -> int:
	if _target_entity is VehicleEntity:
		return (_target_entity as VehicleEntity).health_points
	if _target_entity is StructureEntity:
		return (_target_entity as StructureEntity).health_points

	return 0


func get_target_damage_type_resistance(damage_type: Damage.Type) -> float:
	if _target_entity is VehicleEntity:
		return (_target_entity as VehicleEntity).resistances.get_resistance_for(damage_type)
	if _target_entity is StructureEntity:
		return (_target_entity as StructureEntity).resistances.get_resistance_for(damage_type)

	return 1


func get_attacker_damage_amount() -> int:
	if _attacker_entity is AmmoEntity:
		return (_attacker_entity as AmmoEntity).damage
	if _attacker_entity is VehicleEntity:
		return int((_attacker_entity as VehicleEntity).ammunition.damage * (_attacker_entity as VehicleEntity).damage_modifier)

	return 0


func get_attacker_damage_type() -> Damage.Type:
	if _attacker_entity is AmmoEntity:
		return (_attacker_entity as AmmoEntity).damage_type
	if _attacker_entity is VehicleEntity:
		return (_attacker_entity as VehicleEntity).ammunition.damage_type

	return Damage.Type.KINETIC_LIGHT


func get_time_to_kill(shots_to_kill: int) -> float:
	if (shots_to_kill < 2):
		return 0

	if not (_attacker_entity is VehicleEntity):
		return -1

	var attacker_vic = _attacker_entity as VehicleEntity

	var reloading_duration = 0
	if (shots_to_kill > attacker_vic.magazine_size):
		var number_of_full_reloads = floor(shots_to_kill / attacker_vic.magazine_size)
		# print(number_of_full_reloads)
		reloading_duration += (number_of_full_reloads - 1) * (attacker_vic.reload_duration_s * attacker_vic.magazine_size)
		# print(reloading_duration)
		reloading_duration += (shots_to_kill - (number_of_full_reloads * attacker_vic.magazine_size)) * attacker_vic.reload_duration_s
		# print(reloading_duration)


	var shooting_duration = 0
	var number_or_shots_cd = shots_to_kill - 1
	shooting_duration = number_or_shots_cd * attacker_vic.shot_duration_s


	return (reloading_duration + shooting_duration)


func recalculate():
	current_result.is_valid = true

	if (_attacker_entity == null || _target_entity == null):
		_current_result.is_valid = false
		return

	_current_result.target_health = get_target_health_points()	
	if (_current_result.target_health == 0):
		_current_result.is_valid = false
		return

	_current_result.base_damage = get_attacker_damage_amount()
	if (_current_result.base_damage == 0):
		_current_result.is_valid = false
		return

	var damage_type = get_attacker_damage_type()
	var target_damage_resistance = get_target_damage_type_resistance(damage_type)
	_current_result.target_resistance = int (target_damage_resistance * 100)

	_current_result.count = ceil(float(_current_result.target_health) / (float(_current_result.base_damage) * (1.0 - target_damage_resistance)))
	# print("target hp: %d, damage amount: %d resistance: %f" % [_current_result.target_health, _current_result.base_damage, target_damage_resistance])
	# print("count to kill: %f" % _current_result.count)

	_current_result.time_to_kill = get_time_to_kill(_current_result.count)
