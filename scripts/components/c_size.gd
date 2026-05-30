# 尺寸组件
class_name CSize
extends Component

@export var s_width: float
@export var s_height: float

func _init(w: float = 0.0, h: float = 0.0) -> void:
	s_width = w
	s_height = h