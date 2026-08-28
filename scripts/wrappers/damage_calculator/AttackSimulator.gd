class_name AttackSimulator
extends RefCounted



const TTK_SIMULATION_TIME_STEP: float = 0.05
const DEBUG = true

class SimulationOptions:
	var main_gun_only: bool = false

class SimulationState:
	class GunState:
		var gun_data: ComponentGun
		var ammo_entity_id: String
		var ammo_damage_data: ComponentDamage
		var actual_damage: int = 0

		enum State {READY, COOLDOWN, RELOAD}
		var current_state: State = State.READY
		var state_timer: float = 0.0
		var shots_count: int = 0

	var accumulated_damage: int = 0
	var accumulated_ttk: float = 0

	var target_vitals: ComponentVitals
	var attacker_guns: Array[GunState]
	



func simulate_attack(attacker: GameEntity, target: GameEntity, options: SimulationOptions = SimulationOptions.new()):
	var simulation_result: DamageCalculationResult = DamageCalculationResult.new()
	
	var simulation_state = SimulationState.new()
	
	simulation_state.target_vitals = target.get_component_of_type(ComponentVitals)
	if (simulation_state.target_vitals == null):
		return simulation_result

	var all_attacker_guns_datas = attacker.get_components_of_type(ComponentGun)
	# simulation_state.attacker_guns.resize(all_attacker_guns_datas.size())
	for attacker_gun_data: ComponentGun in all_attacker_guns_datas:
		if attacker_gun_data.ammo_used_ids.is_empty():
			continue

		var new_gun_state: SimulationState.GunState = SimulationState.GunState.new()
		new_gun_state.gun_data = attacker_gun_data
		new_gun_state.ammo_entity_id = attacker_gun_data.ammo_used_ids[0]
		var ammo_data: GameEntity = DataMaster.get_item_entity(new_gun_state.ammo_entity_id)
		new_gun_state.ammo_damage_data = ammo_data.get_component_of_type(ComponentDamage)
		if (new_gun_state.ammo_damage_data == null):
			continue
		
		new_gun_state.actual_damage = int(float((new_gun_state.ammo_damage_data.raw_damage) * new_gun_state.gun_data.damage_modifier) \
		* (1.0 - DataMaster.get_damage_resistance(simulation_state.target_vitals.resistance_id, new_gun_state.ammo_damage_data.damage_type_id)))
		
		simulation_state.attacker_guns.append(new_gun_state)

		if (options.main_gun_only):
			break
	
	if (simulation_state.attacker_guns.is_empty()):
		return simulation_result

	while (simulation_state.accumulated_damage <= simulation_state.target_vitals.max_health):
		for gun in simulation_state.attacker_guns:
			if gun.current_state == SimulationState.GunState.State.READY:
				process_shot(gun, simulation_state)
			
			elif gun.current_state == SimulationState.GunState.State.COOLDOWN:
				process_cooldown(gun, simulation_state)
			
			elif gun.current_state == SimulationState.GunState.State.RELOAD:
				process_reload(gun, simulation_state)
			
			if (simulation_state.accumulated_damage >= simulation_state.target_vitals.max_health):
				break

		if (simulation_state.accumulated_damage >= simulation_state.target_vitals.max_health):
				break
			
		simulation_state.accumulated_ttk += TTK_SIMULATION_TIME_STEP
	
	simulation_result.is_valid = true
	
	simulation_result.add_stats_line("Time to kill", ("%.2f seconds" % simulation_state.accumulated_ttk))

	for gun in simulation_state.attacker_guns:
		simulation_result.counters.append(DamageCalculationResult.Counter.new())
		simulation_result.counters.back().shots_count = gun.shots_count
		simulation_result.counters.back().ammo_type_id = gun.ammo_entity_id
	simulation_result.add_stats_line("Target health:", str(simulation_state.target_vitals.max_health))

	return simulation_result


func process_shot(gun: SimulationState.GunState, simulation_state: SimulationState):
	simulation_state.accumulated_damage += gun.actual_damage
	gun.shots_count += 1
	if (DEBUG): print("SHOT +%s damage! Time step %.2f" % [gun.actual_damage, simulation_state.accumulated_ttk])		
	gun.current_state = SimulationState.GunState.State.COOLDOWN
	gun.state_timer = 0.0
	process_cooldown.call(gun, simulation_state)


func process_cooldown(gun: SimulationState.GunState, simulation_state: SimulationState):
	if (is_equal_approx(gun.state_timer, gun.gun_data.cooldown_duration_s) || gun.state_timer > gun.gun_data.cooldown_duration_s):
		if (DEBUG): print("COOLED! Time step %.2f" % [simulation_state.accumulated_ttk])
		if (gun.shots_count < gun.gun_data.magazine_size):
			gun.current_state = SimulationState.GunState.State.READY
			gun.state_timer = 0
			process_shot.call(gun, simulation_state)
		else:
			gun.current_state = SimulationState.GunState.State.RELOAD
			gun.state_timer = 0
			process_reload.call(gun, simulation_state)
	else:
		gun.state_timer += TTK_SIMULATION_TIME_STEP


func process_reload(gun: SimulationState.GunState, simulation_state: SimulationState):
	if (is_equal_approx(gun.state_timer, gun.gun_data.reload_duration_s) || gun.state_timer >= gun.gun_data.reload_duration_s):
		if (DEBUG): print("RELOADED! Time step %.2f" % [simulation_state.accumulated_ttk])
		gun.current_state = SimulationState.GunState.State.READY
		gun.state_timer = 0
		process_shot.call(gun, simulation_state)
	else:
		gun.state_timer += TTK_SIMULATION_TIME_STEP
