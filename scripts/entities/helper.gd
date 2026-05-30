class_name EntityHelper
extends Node

static func transform_comp_set(entity: TEntity):
	var transform = entity.get_component(CTransform)
	Loggie.notice("Entity on_ready: entity type is ", entity.get_class())
	Loggie.notice("Entity on_ready: component resources size =", entity.component_resources.size())
	if transform == null:
		Loggie.error("CTransform component is null")
		return
	var body = entity as Node
	if body.position != Vector2.ZERO:
		transform.position = body.position
	if transform.position != Vector2.ZERO and body.position == Vector2.ZERO:
		body.position = transform.position

static func size_comp_set(entity: TEntity):
	var size = entity.get_component(CSize) as CSize
	if size == null:
		Loggie.error("CSize component is null")
		return
	var body = entity as Node as PhysicsBody2D
	var collision_shape = body.get_child(0) as CollisionShape2D
	var rect = collision_shape.shape as RectangleShape2D
	rect.size = Vector2(size.s_width, size.s_height)
	Loggie.notice("SizeEntity on_ready: size width =", size.s_width, ", height =", size.s_height)

static func _check_delay(entity: Entity, delta: float) -> bool:
	var c_delay = entity.get_component(CDelay)
	if c_delay != null and c_delay.s_delay_time > 0:
		if c_delay.delay_timer + delta < c_delay.s_delay_time:
			c_delay.delay_timer += delta
			return true
	return false