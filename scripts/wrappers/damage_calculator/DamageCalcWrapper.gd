extends Node



signal updated()
signal recalculated(DamageCalculationResult)

@export var _attacker_entity: GameEntity
var attacker_entity: GameEntity:
	get:
		return _attacker_entity
	set(value):
		_attacker_entity = value
		updated.emit()


@export var _target_entity: GameEntity
var target_entity: GameEntity:
	get:
		return _target_entity
	set(value):
		_target_entity = value
		updated.emit()

var _vic_on_vic_calc: VicOnVicCalc = VicOnVicCalc.new()

var current_result: DamageCalculationResult = DamageCalculationResult.new()


func _ready() -> void:
	pass



# func get_target_health_points() -> int:
# 	var vitals_component: VitalsComponent = _target_entity.get_component(VitalsComponent)
# 	if vitals_component == null:
# 		return 0
# 	return vitals_component.hp


# func get_attacker_damage_amount() -> int:
# 	if _attacker_entity is AmmoEntity:
# 		return (_attacker_entity as AmmoEntity).damage
# 	if _attacker_entity is VehicleEntity:
# 		var main_gun_attack: AttackComponent = _attacker_entity.get_component(AttackComponent)
# 		if (main_gun_attack == null):
# 			return 0

# 		return int(main_gun_attack.ammo_type.damage * main_gun_attack.damage_modifier)

# 	return 0


# func get_attacker_damage_type() -> DamageType:
# 	if _attacker_entity is AmmoEntity:
# 		return (_attacker_entity as AmmoEntity).damage_type
# 	if _attacker_entity is VehicleEntity:
# 		var main_gun_attack: AttackComponent = _attacker_entity.get_component(AttackComponent)
# 		if (main_gun_attack == null):
# 			return null

# 		return main_gun_attack.ammo_type.damage_type

# 	return null


func recalculate():
	if (_attacker_entity == null || _target_entity == null):
		recalculated.emit(DamageCalculationResult.new())
		return

	if ((_attacker_entity.has_component(AttackComponent) && _target_entity.has_component(VitalsComponent))):
		current_result = _vic_on_vic_calc.simulate_attack(attacker_entity, target_entity)
		recalculated.emit(current_result)
