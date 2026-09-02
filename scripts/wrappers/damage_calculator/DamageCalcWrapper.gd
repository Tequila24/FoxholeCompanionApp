extends Node



signal updated()
signal recalculated(DamageCalculationResult)

var _attacker_entity: GameEntity
var attacker_entity: GameEntity:
	get:
		return _attacker_entity
	set(value):
		_attacker_entity = value
		updated.emit()


var _target_entity: GameEntity
var target_entity: GameEntity:
	get:
		return _target_entity
	set(value):
		_target_entity = value
		updated.emit()


var _attack_simulator: AttackSimulator = AttackSimulator.new()
var current_result: DamageCalculationResult = DamageCalculationResult.new()


func _ready() -> void:
	pass


func recalculate():
	if (_attacker_entity == null || _target_entity == null):
		recalculated.emit(DamageCalculationResult.new())
		print(current_result.is_valid)
		return
	
	if ((_attacker_entity.has_component_type(ComponentGun) && _target_entity.has_component_type(ComponentVitals))):
		var result = _attack_simulator.simulate_attack(attacker_entity, target_entity)
		recalculated.emit(result)
		return

	# empty result
	recalculated.emit(DamageCalculationResult.new())
