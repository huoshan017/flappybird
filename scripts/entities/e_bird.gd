@tool

class_name EBird
extends TEntity

func on_ready() -> void:
	#EntityHelper.transform_comp_set(self)
	var character_body = self as Node as CharacterBody2D
	var collision_obj = character_body.get_child(0) as CollisionShape2D
	var collisionShapeObj = CCollisionShapeObject.new(Enums.CollisionObjectType.CHARACTER, character_body, Enums.ShapeType.SHAPE_CAPSULE, collision_obj)
	add_component(collisionShapeObj)
	var velocity = get_component(CVelocity)
	velocity.velocity.x = Constants.CHARACTER_HORIZENTAL_SPEED
	Global.player = self
	Loggie.notice("EBird on_ready: initial position x =", character_body.position.x, ", y =", character_body.position.y)
