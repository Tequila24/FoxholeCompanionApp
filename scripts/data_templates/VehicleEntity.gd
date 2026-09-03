class_name VehicleEntity
extends GameEntity


var vehicle_type: Enums.VehicleType = Enums.VehicleType.ANY


func _init() -> void:
	entity_type = Enums.EntityType.VEHICLE