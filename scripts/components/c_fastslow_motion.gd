# 快慢运动组件
class_name CFastSlowMotion
extends Component

@export var basic_linear_velocity: Vector2 = Vector2(-1, 0) # 基础线速度，矢量带方向的
@export var velocity_factor_list: Array[float] = [1] # 速度因子
@export var segment_duration: float = 2.0 # 每段持续时间，单位为秒
@export var is_loop: bool = false # 是否循环播放