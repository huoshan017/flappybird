@tool

class_name EBird
extends TEntity

#func define_components() -> Array:
#	return [
#		CInput.new(),
#		CTransform.new(),
#		CVelocity.new(),
#		CCollisionShapeObject.new(Enums.CollisionObjectType.CHARACTER, owner, Enums.ShapeType.SHAPE_RECTANGLE, owner.get_child(0)),
#	]

func on_ready() -> void:
	var character_body = self as Node as CharacterBody2D
	var collision_obj = character_body.get_child(0) as CollisionShape2D
	var collisionShapeObj = CCollisionShapeObject.new(Enums.CollisionObjectType.CHARACTER, character_body, Enums.ShapeType.SHAPE_RECTANGLE, collision_obj)
	add_component(collisionShapeObj)
	var velocity = get_component(CVelocity)
	velocity.velocity.x = Constants.CHARACTER_HORIZENTAL_SPEED
	#character_body.velocity = velocity.velocity
	Loggie.notice("EBird on_ready: initial position x =", character_body.position.x, ", y =", character_body.position.y)
	var transform = get_component(CTransform)
	if character_body.position != Vector2.ZERO:
		transform.position = character_body.position
	if transform.position != Vector2.ZERO and character_body.position == Vector2.ZERO:
		character_body.position = transform.position

	Global.player = self

func _input(event: InputEvent) -> void:
	var input_comp = get_component(CInput) as CInput
	input_comp.handle_input_event(event)
