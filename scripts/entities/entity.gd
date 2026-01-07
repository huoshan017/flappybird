class_name EntityUtils

# Create entity
static func create_entity(entity_type: Enums.EntityType) -> Entity:
	var entity = Entity.new()
	match entity_type:
		Enums.EntityType.Bird:
			entity.add_component(CTransform.new())
			entity.add_component(CVelocity.new())
		Enums.EntityType.PipeUp, Enums.EntityType.PipeDown:
			entity.add_component(CTransform.new())
		Enums.EntityType.Floor:
			entity.add_component(CTransform.new())
	Signals.EntityCreated.emit(entity)
	return entity

# physics attach to entity
static func physics_attach_entity(world: World, entity: Entity, ct: Enums.CollisionObjectType, cs: Enums.ShapeType):
	var collision_object: CollisionObject2D = null
	match ct:
		Enums.CollisionObjectType.RIGID:
			collision_object = RigidBody2D.new()
		Enums.CollisionObjectType.STATIC:
			collision_object = StaticBody2D.new()
		Enums.CollisionObjectType.CHARACTER:
			collision_object = CharacterBody2D.new()
		Enums.CollisionObjectType.AREA:
			collision_object = Area2D.new()

	if collision_object == null:
		push_error("Invalid collision object type")

	var shape: CollisionShape2D = null
	match cs:
		Enums.ShapeType.SHAPE_CIRCLE:
			shape.shape = CircleShape2D.new()
		Enums.ShapeType.SHAPE_RECTANGLE:
			shape.shape = RectangleShape2D.new()
		Enums.ShapeType.SHAPE_POLYGON:
			shape.shape = ConvexPolygonShape2D.new()
		Enums.ShapeType.SHAPE_CAPSULE:
			shape.shape = CapsuleShape2D.new()
		Enums.ShapeType.SHAPE_SEGMENT:
			shape.shape = SegmentShape2D.new()

	if shape == null:
		push_error("Invalid shape type")

	collision_object.add_child(shape)
	world.add_child(collision_object)

	var comp_collision_shape = CCollisionShapeObject.new(ct, collision_object, cs, shape)
	entity.add_component(comp_collision_shape)

	return [collision_object, shape]


# Create bird entity
static func create_bird() -> Entity:
	var bird = Entity.new()
	return bird

static func create_pipe() -> Entity:
	var pipe = Entity.new()
	return pipe

static func create_ground() -> Entity:
	var ground = Entity.new()
	return ground