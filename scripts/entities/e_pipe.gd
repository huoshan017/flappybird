@tool

class_name EPipe
extends TEntity

func on_ready() -> void:
	#EntityHelper.transform_comp_set(self)
	EntityHelper.size_comp_set(self)
	var static_body = self as Node as StaticBody2D
	if static_body == null:
		Loggie.error("EPipe _ready: StaticBody2D is null")
		return
	var collision_obj = static_body.get_child(0) as CollisionShape2D
	var collision_object = CCollisionShapeObject.new(Enums.CollisionObjectType.STATIC, static_body, Enums.ShapeType.SHAPE_RECTANGLE, collision_obj)
	add_component(collision_object)
	Loggie.notice("EPipe on_ready: initial position x = %f, y = %f, size width = %f, height =%f" % [static_body.position.x, static_body.position.y, collision_obj.shape.extents.x * 2, collision_obj.shape.extents.y * 2])
