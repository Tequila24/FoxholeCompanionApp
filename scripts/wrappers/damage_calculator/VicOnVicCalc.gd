class_name VicOnVicCalc
extends RefCounted



const INLINE_TEXT_FMT: String = "[img width=1em]%s[/img]"
const TTK_SIMULATION_TIME_STEP: float = 0.05
const TTK_TO_MINUTES_LIMIT: float = 120
const DEBUG: bool = true


#
class GunSimulationData:
	enum GunState {READY, COOLDOWN, RELOAD}
	var damage: int = 1
	var magazine_size: int = 1
	var reload_duration_s: float = 0.1
	var cooldown_duration_s: float = 0.1
	var state: GunState = GunState.READY
	var state_timer: float = 0.0
	var ammo_entity_id: String = ""
	var shots_count: int = 0

class SimulationData:
	var attacker_guns: Array[GunSimulationData]
	var target_health: int
	var time_to_kill: float

var _accumulated_damage: int = 0
var _accumulated_time_to_kill: float = 0

var _all_attack_components: Array[ComponentGun]	
var _simulation_data: SimulationData 



func get_target_damage_type_resistance(target_entity: GameEntity, damage_type_id: String) -> float:
	var vitals_component: ComponentVitals = target_entity.get_component_of_type(ComponentVitals)
	if (vitals_component == null):
		return 0

	return DataMaster.get_resistance_to_damage_type(vitals_component.resistance_id, damage_type_id)


# func get_target_damage_type_resistance_as_string(target_entity: GameEntity, damage_type: DamageType) -> String:
# 	var resistance_component: DamageResistanceComponent = target_entity.get_component(DamageResistanceComponent)
# 	if (resistance_component == null):
# 		return ""

# 	return resistance_component.get_resistance_for_as_string(damage_type)


func get_target_health_points(target_entity: GameEntity) -> int:
	var vitals_component: ComponentVitals = target_entity.get_component_of_type(ComponentVitals)
	if vitals_component == null:
		return 0
	return vitals_component.max_health


func simulate_attack(attacker_entity: GameEntity, target_entity: GameEntity) -> DamageCalculationResult:
	var result: DamageCalculationResult = DamageCalculationResult.new()
	
	_simulation_data = SimulationData.new()

	_all_attack_components.assign(attacker_entity.get_components_of_type(ComponentGun))
	if (_all_attack_components.is_empty()):
		result.is_valid = false
		print("no attack component found")
		return result

	for gun_component: ComponentGun in _all_attack_components:
		var new_gun_sim_data = GunSimulationData.new()
		
		var raw_damage: int = 0
		var damage_resistance: float = 0
		
		var ammo_entity: ItemEntity = DataMaster.get_item_entity(gun_component.ammo_used_ids.get(0))
		if (ammo_entity == null):
			if DEBUG: print("No ammo type found")
			continue
		if (not ammo_entity.has_component_type(ComponentDamage)):
			if DEBUG: print("No damage component on ammo entity")
			continue

		var damage_component: ComponentDamage = ammo_entity.get_component_of_type(ComponentDamage)
		raw_damage = damage_component.raw_damage

		damage_resistance = (1.0 - get_target_damage_type_resistance(target_entity, damage_component.damage_type_id))
		# print("Target: %s resistance for %s - %s" % [target_entity.name, damage_component.damage_type_id, damage_resistance])

		new_gun_sim_data.damage = raw_damage * gun_component.damage_modifier * damage_resistance
		# print("Target: %s damage from %s - %s" % [target_entity.name, ammo_entity.id, all_guns.back().damage])
		if (new_gun_sim_data.damage == 0):
			continue

		new_gun_sim_data.reload_duration_s = gun_component.reload_duration_s
		var actual_cooldown: float = 0
		if (gun_component.magazine_size > 1 && is_equal_approx(gun_component.cooldown_duration_s, 0.0)):
			actual_cooldown = 60 / gun_component.fire_rate
		else:
			actual_cooldown = gun_component.cooldown_duration_s
		new_gun_sim_data.cooldown_duration_s = actual_cooldown

		new_gun_sim_data.magazine_size = gun_component.magazine_size
		new_gun_sim_data.state = GunSimulationData.GunState.READY
		new_gun_sim_data.state_timer = 0

		_simulation_data.attacker_guns.append(new_gun_sim_data)

		if DEBUG: print("Gun: %s damage: %s mag_size: %s" % [_simulation_data.attacker_guns.back().ammo_entity_id, _simulation_data.attacker_guns.back().damage, _simulation_data.attacker_guns.back().magazine_size])

	# print("Calculated guns count: %s" % str(_simulation_data.attacker_guns.size()))
	# print("Gun type %s mag size %s" % [_simulation_data.attacker_guns.get(0).ammo_entity_id, _simulation_data.attacker_guns.get(0).magazine_size])

	if (_simulation_data.attacker_guns.is_empty()):
		result.is_valid = false
		if DEBUG: print("no guns found found")
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
		for gun in _simulation_data.attacker_guns:
			
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
		result.guns_counters.append(DamageCalculationResult.GunCalculationResult.new(gun_sim_data.ammo_entity_id, gun_sim_data.shots_count))

	result.add_stats_line("Target health", ("%d" % _simulation_data.target_health))	
	# var target_resistances_str: String = ""
	# for gun in _simulation_data.attacker_guns:
	# 	target_resistances_str += get_target_damage_type_resistance_as_string(target_entity, gun.ammo_type.damage_type)
	# 	target_resistances_str += " "
	# result.add_stats_line("Target resistances", target_resistances_str)
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
			print("SHOT +%s damage! Time step %.2f" % [gun.damage, _accumulated_time_to_kill])


func process_cooldown(gun: GunSimulationData, gun_idx: int):
	# var cooldown_duration = (_all_attack_components[gun_idx] as ComponentGun).cooldown_duration_s

	if (is_equal_approx(gun.state_timer, gun.cooldown_duration_s) || gun.state_timer > gun.cooldown_duration_s):
		if (DEBUG):
			print("COOLED! Time step %.2f" % [_accumulated_time_to_kill])
			print("Shots count: %d - Mag Size %d" % [_simulation_data.attacker_guns[gun_idx].shots_count, gun.magazine_size])
		if (_simulation_data.attacker_guns[gun_idx].shots_count < gun.magazine_size):
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
	# var reload_duration = (_all_attack_components[gun_idx] as ComponentGun).reload_duration_s

	if (is_equal_approx(gun.state_timer, gun.reload_duration_s) || gun.state_timer >= gun.reload_duration_s):
		if (DEBUG):
			print("RELOADED! Time step %.2f" % [_accumulated_time_to_kill])
		gun.state = GunSimulationData.GunState.READY
		gun.state_timer = 0
		process_shot.call(gun, gun_idx)
	else:
		gun.state_timer += TTK_SIMULATION_TIME_STEP
