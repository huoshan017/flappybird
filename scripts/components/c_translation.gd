# 平移组件
class_name CTranslation
extends Component

@export var s_speed: float # 速度
@export var s_direction: Vector2 # 方向
@export var s_movement_distance: float # 移动距离
@export var s_is_cycle: bool # 是否循环
var is_reversed: bool = false # 是否反向
var moved_distance: float = 0.0 # 已移动距离

func _init(s: float = 0, d: Vector2 = Vector2.ZERO, md: float = 0, ic: bool = false) -> void:
	s_speed = s
	s_direction = d.normalized()
	s_movement_distance = md
	s_is_cycle = ic