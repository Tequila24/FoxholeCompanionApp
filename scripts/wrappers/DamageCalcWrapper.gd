extends Node


const TTK_TIME_STEP = 0.1

signal updated()
signal recalculated()

@export var _attacker_entity: GameEntity
@export var attacker_entity: GameEntity:
	get:
		return _attacker_entity

@export var _target_entity: GameEntity
@export var target_entity: GameEntity:
	get:
		return _target_entity

class CalcResult:
	class GunResult:
		var base_damage: int
		var ammo_type: GameEntity
		var shots_count: int

	var is_valid: bool = true
	var guns_results: Array[GunResult]
	var target_health: int = 0
	var target_resistance: int = 0
	var time_to_kill: float = 0

	func reset():
		is_valid = true
		guns_results.clear()
		target_health = 0
		target_resistance = 0
		time_to_kill = 0


class GunSimulationData:
	enum GunState {READY, COOLDOWN, RELOAD}
	var damage: int = 1
	var state: GunState = GunState.READY
	var state_timer: float = 0.0


var _current_result: CalcResult = CalcResult.new()
var current_result: CalcResult:
	get:
		return _current_result

var _accumulated_damage: int = 0
var _accumulated_time_to_kill: float = 0
var _all_attack_components: Array[AttackComponent]



func _ready() -> void:
	pass


func set_attacker_entity(new_entity: GameEntity): 
	_attacker_entity = new_entity
	updated.emit()


func set_target_entity(new_entity: GameEntity):
	_target_entity = new_entity
	updated.emit()


func get_target_health_points() -> int:
	var vitals_component: VitalsComponent = _target_entity.get_component(VitalsComponent)
	if vitals_component == null:
		return 0
	
	return vitals_component.hp


func get_target_damage_type_resistance(damage_type: DamageType) -> float:
	var resistance_component: DamageResistanceComponent = _target_entity.get_component(DamageResistanceComponent)
	if (resistance_component == null):
		return 0

	return resistance_component.get_resistance_for(damage_type)


func get_attacker_damage_amount() -> int:
	if _attacker_entity is AmmoEntity:
		return (_attacker_entity as AmmoEntity).damage
	if _attacker_entity is VehicleEntity:
		var main_gun_attack: AttackComponent = _attacker_entity.get_component(AttackComponent)
		if (main_gun_attack == null):
			return 0

		return int(main_gun_attack.ammo_type.damage * main_gun_attack.damage_modifier)

	return 0


func get_attacker_damage_type() -> DamageType:
	if _attacker_entity is AmmoEntity:
		return (_attacker_entity as AmmoEntity).damage_type
	if _attacker_entity is VehicleEntity:
		var main_gun_attack: AttackComponent = _attacker_entity.get_component(AttackComponent)
		if (main_gun_attack == null):
			return null

		return main_gun_attack.ammo_type.damage_type

	return null


func get_time_to_kill(shots_to_kill: int) -> float:
	if (shots_to_kill < 2):
		return 0

	if not (_attacker_entity is VehicleEntity):
		return -1

	# var attacker_vic = _attacker_entity as VehicleEntity
	var main_gun_attack: AttackComponent = _attacker_entity.get_component(AttackComponent)
	if (main_gun_attack == null):
		return 0

	var reloading_duration = 0
	if (shots_to_kill > main_gun_attack.magazine_size):
		var number_of_full_reloads = floor(shots_to_kill / float(main_gun_attack.magazine_size))
		# print(number_of_full_reloads)
		reloading_duration += (number_of_full_reloads - 1) * (main_gun_attack.reload_duration_s * main_gun_attack.magazine_size)
		# print(reloading_duration)
		reloading_duration += (shots_to_kill - (number_of_full_reloads * main_gun_attack.magazine_size)) * main_gun_attack.reload_duration_s
		# print(reloading_duration)


	var shooting_duration = 0
	var number_or_shots_cd = shots_to_kill - 1
	shooting_duration = number_or_shots_cd * main_gun_attack.cooldown_duration_s


	return (reloading_duration + shooting_duration)


func recalculate():
	_current_result.reset()

	if (_attacker_entity == null || _target_entity == null):
		_current_result.is_valid = false
		return

	_current_result.target_health = get_target_health_points()	
	if (_current_result.target_health == 0):
		_current_result.is_valid = false
		return

	if ((_attacker_entity.category is CategoryVehicle && _target_entity.category is CategoryVehicle)):
		_simulate_attack()


func _simulate_attack():
	_all_attack_components.assign(attacker_entity.get_all_components(AttackComponent))

	var all_guns: Array[GunSimulationData]
	for component: AttackComponent in _all_attack_components:
		all_guns.append(GunSimulationData.new())
		all_guns.back().damage = component.ammo_type.damage * component.damage_modifier * (1.0 - get_target_damage_type_resistance(component.ammo_type.damage_type))
		all_guns.back().state = GunSimulationData.GunState.READY
		all_guns.back().state_timer = 0

		_current_result.guns_results.append(CalcResult.GunResult.new())
		_current_result.guns_results.back().ammo_type = component.ammo_type
		_current_result.guns_results.back().base_damage = component.ammo_type.damage


	_accumulated_damage = 0
	_accumulated_time_to_kill = 0


	while _accumulated_damage < _current_result.target_health:
		var gun_idx: int = 0
		for gun in all_guns:
			
			if gun.state == GunSimulationData.GunState.READY:
				process_shot.call(gun, gun_idx)			
			
			elif gun.state == GunSimulationData.GunState.COOLDOWN:
				process_cooldown.call(gun, gun_idx)
			
			elif gun.state == GunSimulationData.GunState.RELOAD:
				process_reload.call(gun, gun_idx)
			
			gun_idx += 1

		if (_accumulated_damage >= _current_result.target_health):
			break
		
		_accumulated_time_to_kill += TTK_TIME_STEP



	_current_result.time_to_kill = _accumulated_time_to_kill

	recalculated.emit()


func process_shot(gun: GunSimulationData, gun_idx: int):
	_accumulated_damage += gun.damage
	# print("Accumulated damage %d" % _accumulated_damage)
	_current_result.guns_results[gun_idx].shots_count += 1
	gun.state = GunSimulationData.GunState.COOLDOWN
	gun.state_timer = 0
	process_cooldown.call(gun, gun_idx)

	print("SHOT! Time step %.2f" % [_accumulated_time_to_kill])


func process_cooldown(gun: GunSimulationData, gun_idx: int):
	var cooldown_duration = (_all_attack_components[gun_idx] as AttackComponent).cooldown_duration_s

	if (is_equal_approx(gun.state_timer, cooldown_duration) || gun.state_timer > cooldown_duration):
		print("COOLED! Time step %.2f" % [_accumulated_time_to_kill])
		if (_current_result.guns_results[gun_idx].shots_count < (_all_attack_components[gun_idx] as AttackComponent).magazine_size):
			gun.state = GunSimulationData.GunState.READY
			gun.state_timer = 0
			process_shot.call(gun, gun_idx)
		else:
			gun.state = GunSimulationData.GunState.RELOAD
			gun.state_timer = 0
			process_reload.call(gun, gun_idx)
	else:
		# print("Cooldown added: %f" % gun.state_timer)
		gun.state_timer += TTK_TIME_STEP
		


func process_reload(gun: GunSimulationData, gun_idx: int):
	var reload_duration = (_all_attack_components[gun_idx] as AttackComponent).reload_duration_s

	if (is_equal_approx(gun.state_timer, reload_duration) || gun.state_timer >= reload_duration):
		print("RELOADED! Time step %.2f" % [_accumulated_time_to_kill])
		gun.state = GunSimulationData.GunState.READY
		gun.state_timer = 0
		process_shot.call(gun, gun_idx)
	else:
		gun.state_timer += TTK_TIME_STEP
