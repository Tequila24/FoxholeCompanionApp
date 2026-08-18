class_name VicOnVicCalc
extends RefCounted



const INLINE_TEXT_FMT: String = "[img width=1em]%s[/img]"
const TTK_SIMULATION_TIME_STEP: float = 0.05
const TTK_TO_MINUTES_LIMIT: float = 120
const DEBUG: bool = false


#
class GunSimulationData:
	enum GunState {READY, COOLDOWN, RELOAD}
	var damage: int = 1
	var state: GunState = GunState.READY
	var state_timer: float = 0.0
	var ammo_type: AmmoEntity = null
	var shots_count: int = 0

class SimulationData:
	var attacker_guns: Array[GunSimulationData]
	var target_health: int
	var time_to_kill: float

var _accumulated_damage: int = 0
var _accumulated_time_to_kill: float = 0

var _all_attack_components: Array[AttackComponent]	
var _simulation_data: SimulationData 



func get_target_damage_type_resistance(target_entity: GameEntity, damage_type: DamageType) -> float:
	var resistance_component: DamageResistanceComponent = target_entity.get_component(DamageResistanceComponent)
	if (resistance_component == null):
		return 0

	return resistance_component.get_resistance_for(damage_type)


func get_target_damage_type_resistance_as_string(target_entity: GameEntity, damage_type: DamageType) -> String:
	var resistance_component: DamageResistanceComponent = target_entity.get_component(DamageResistanceComponent)
	if (resistance_component == null):
		return ""

	return resistance_component.get_resistance_for_as_string(damage_type)


func get_target_health_points(target_entity: GameEntity) -> int:
	var vitals_component: VitalsComponent = target_entity.get_component(VitalsComponent)
	if vitals_component == null:
		return 0
	return vitals_component.hp


func simulate_attack(attacker_entity: GameEntity, target_entity: GameEntity) -> DamageCalculationResult:
	var result: DamageCalculationResult = DamageCalculationResult.new()
	
	_simulation_data = SimulationData.new()

	_all_attack_components.assign(attacker_entity.get_all_components(AttackComponent))
	if (_all_attack_components.is_empty()):
		result.is_valid = false
		return result

	var all_guns: Array[GunSimulationData]
	for component: AttackComponent in _all_attack_components:
		all_guns.append(GunSimulationData.new())
		var damage_resistance: float = (1.0 - get_target_damage_type_resistance(target_entity, component.ammo_type.damage_type))
		all_guns.back().damage = component.ammo_type.damage * component.damage_modifier * damage_resistance
		if (all_guns.back().damage == 0):
			all_guns.pop_back()
			continue
		all_guns.back().state = GunSimulationData.GunState.READY
		all_guns.back().state_timer = 0

		_simulation_data.attacker_guns.append(GunSimulationData.new())
		_simulation_data.attacker_guns.back().ammo_type = component.ammo_type
		_simulation_data.attacker_guns.back().damage = component.ammo_type.damage

	if (_simulation_data.attacker_guns.is_empty()):
		result.is_valid = false
		return result


	_accumulated_damage = 0
	_accumulated_time_to_kill = 0

	_simulation_data.target_health = get_target_health_points(target_entity)

	var step: int = 0
	while _accumulated_damage < _simulation_data.target_health:
		if (step > 9999999):
			print("Too many steps to count, stopping simulation")
			return result


		var gun_idx: int = 0
		for gun in all_guns:
			
			if gun.state == GunSimulationData.GunState.READY:
				process_shot.call(gun, gun_idx)			
			
			elif gun.state == GunSimulationData.GunState.COOLDOWN:
				process_cooldown.call(gun, gun_idx)
			
			elif gun.state == GunSimulationData.GunState.RELOAD:
				process_reload.call(gun, gun_idx)
			
			gun_idx += 1

		if (_accumulated_damage >= _simulation_data.target_health):
			break
		
		_accumulated_time_to_kill += TTK_SIMULATION_TIME_STEP
		step += 1

	_simulation_data.time_to_kill = _accumulated_time_to_kill

	result.is_valid = true

	for gun_sim_data in _simulation_data.attacker_guns:
		result.guns_counters.append(DamageCalculationResult.GunCalculationResult.new(gun_sim_data.ammo_type, gun_sim_data.shots_count))


	result.add_stats_line("Target health", ("%d" % _simulation_data.target_health))	
	var target_resistances_str: String = ""
	for gun in _simulation_data.attacker_guns:
		target_resistances_str += get_target_damage_type_resistance_as_string(target_entity, gun.ammo_type.damage_type)
		target_resistances_str += " "
	result.add_stats_line("Target resistances", target_resistances_str)
	if (_simulation_data.time_to_kill < TTK_TO_MINUTES_LIMIT):
		result.add_stats_line("Time to kill", ("%.2f seconds" % _simulation_data.time_to_kill))
	else:
		result.add_stats_line("Time to kill", ("%.2f minutes" % (_simulation_data.time_to_kill / 60.0)))


	return result


func process_shot(gun: GunSimulationData, gun_idx: int):
	_accumulated_damage += gun.damage
	_simulation_data.attacker_guns[gun_idx].shots_count += 1
	gun.state = GunSimulationData.GunState.COOLDOWN
	gun.state_timer = 0
	process_cooldown.call(gun, gun_idx)

	if (DEBUG):
			print("SHOT! Time step %.2f" % [_accumulated_time_to_kill])


func process_cooldown(gun: GunSimulationData, gun_idx: int):
	var cooldown_duration = (_all_attack_components[gun_idx] as AttackComponent).cooldown_duration_s

	if (is_equal_approx(gun.state_timer, cooldown_duration) || gun.state_timer > cooldown_duration):
		if (DEBUG):
			print("COOLED! Time step %.2f" % [_accumulated_time_to_kill])
		if (_simulation_data.attacker_guns[gun_idx].shots_count < (_all_attack_components[gun_idx] as AttackComponent).magazine_size):
			gun.state = GunSimulationData.GunState.READY
			gun.state_timer = 0
			process_shot.call(gun, gun_idx)
		else:
			gun.state = GunSimulationData.GunState.RELOAD
			gun.state_timer = 0
			process_reload.call(gun, gun_idx)
	else:
		gun.state_timer += TTK_SIMULATION_TIME_STEP
		

func process_reload(gun: GunSimulationData, gun_idx: int):
	var reload_duration = (_all_attack_components[gun_idx] as AttackComponent).reload_duration_s

	if (is_equal_approx(gun.state_timer, reload_duration) || gun.state_timer >= reload_duration):
		if (DEBUG):
			print("RELOADED! Time step %.2f" % [_accumulated_time_to_kill])
		gun.state = GunSimulationData.GunState.READY
		gun.state_timer = 0
		process_shot.call(gun, gun_idx)
	else:
		gun.state_timer += TTK_SIMULATION_TIME_STEP
