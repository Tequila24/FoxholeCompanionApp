class_name VehicleEntity
extends GameEntity



var vehicle_type: Enums.VehicleType = Enums.VehicleType.ANY


func _init() -> void:
	type = Enums.EntityType.VEHICLE