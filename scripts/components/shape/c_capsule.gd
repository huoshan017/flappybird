class_name CCapsule
extends Component

@export var height: float = 2.0
@export var radius: float = 0.5

var capsule_: CapsuleShape2D = CapsuleShape2D.new()

func _init(r: float = radius, h: float = height) -> void:
	capsule_.radius = r
	capsule_.height = h