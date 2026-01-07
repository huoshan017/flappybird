class_name CCircle
extends Component

@export var radius: float = 1.0
var circle_: CircleShape2D = CircleShape2D.new()

func _init(r: float = radius) -> void:
	circle_.radius = r
