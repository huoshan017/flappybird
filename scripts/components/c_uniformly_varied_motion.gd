# 匀变速运动组件
class_name CUniformlyVariedMotion
extends Component

@export var initial_velocity: Vector2 = Vector2.ZERO # 初始速度，矢量带方向的
@export var acceleration_factor: Vector2 = Vector2.ZERO # 加速度，矢量带方向的
@export var max_speed: float = 100.0 # 最大速度，标量
@export var max_speed_distance: float = 200.0 # 达到最大速度所需的距离，标量
@export var is_mirror_after_max_speed: bool = false # 是否在达到最大速度后镜像加速度，即加速度方向与初始速度相反
@export var is_loop: bool = false # 是否循环播放