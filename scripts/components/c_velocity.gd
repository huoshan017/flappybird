class_name CVelocity
extends Component

@export var velocity: Vector2 = Vector2.ZERO

func _init(vel: Vector2 = Vector2.ZERO) -> void:
	velocity = vel