class_name CCollisionShapeObject
extends Component

var collision_type_: Enums.CollisionObjectType
var collision_obj_: CollisionObject2D
var shape_type_: Enums.ShapeType
var shape_obj_: CollisionShape2D

func _init(ct: Enums.CollisionObjectType, co: CollisionObject2D, st: Enums.ShapeType, so: CollisionShape2D) -> void:
	collision_type_ = ct
	collision_obj_ = co
	shape_type_ = st
	shape_obj_ = so
