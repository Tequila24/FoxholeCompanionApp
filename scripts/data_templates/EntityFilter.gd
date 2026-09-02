class_name EntityFilter
extends Object


const DEBUG: bool = false

var allowed_factions: Enums.Faction = Enums.Faction.ANY
var component_type_filter: Array[Variant.Type] = []
var allowed_entity_types: Enums.EntityType = Enums.EntityType.ANY
var allowed_vehicle_types: Enums.VehicleType = Enums.VehicleType.ANY



func check(entity: GameEntity) -> bool:
	if DEBUG: print("Cheking entity: %s" % entity.name)

	if (not _check_faction(entity)):
		if DEBUG: print("Filtered by allowed_factions filter")
		return false

	if (not _check_components(entity)):
		if DEBUG: print("Filtered by component filter filter")
		return false

	if (not _check_entity_type(entity)):
		if DEBUG: print("Filtered by entity type filter")
		return false

	if (not _check_vehicle_type(entity)):
		if DEBUG: print("Filtered by vehicle type filter")
		return false

	return true


func _check_faction(entity: GameEntity) -> bool:
	if (entity.faction == Enums.Faction.NEUTRAL):
		return true

	return (entity.faction & allowed_factions)


func _check_components(entity: GameEntity) -> bool:
	for component_type in component_type_filter:
		if (not entity.has_component_type(component_type)):
			return false
	return true


func _check_vehicle_type(vehicle_entity: VehicleEntity) -> bool:
	if (not vehicle_entity):
		if DEBUG: print("Not a vehicle!")
		return true

	if not (vehicle_entity.vehicle_type & allowed_vehicle_types):

		return false

	return true


func _check_entity_type(entity: GameEntity) -> bool:
	return (entity.type & allowed_entity_types)
