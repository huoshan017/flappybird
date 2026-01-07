class_name CTransform
extends Component

@export var position: Vector2 # 位置
@export var rotation: float # 旋转，单位为度

func _init(pos: Vector2 = Vector2.ZERO, rot: float = 0.0) -> void:
	position = pos
	rotation = rot