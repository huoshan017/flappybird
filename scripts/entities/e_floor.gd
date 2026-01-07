@tool

class_name EFloor
extends TEntity

func on_ready() -> void:
	var static_body = self as Node as StaticBody2D
	if static_body == null:
		Loggie.error("EFloor _ready: StaticBody2D is null")
		return
	var collision_obj = static_body.get_child(0) as CollisionShape2D
	var collision_object = CCollisionShapeObject.new(Enums.CollisionObjectType.STATIC, static_body, Enums.ShapeType.SHAPE_WORLD_BOUNDARY, collision_obj)
	add_component(collision_object)
	var transform = get_component(CTransform)
	if transform == null:
		Loggie.error("EFloor _ready: CTransform is null")
		return
	if static_body.position != Vector2.ZERO:
		transform.position = static_body.position
	if transform.position != Vector2.ZERO and static_body.position == Vector2.ZERO:
		static_body.position = transform.position
