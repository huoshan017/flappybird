# 风火轮组件
class_name CHotWheels
extends Component

@export var item: PackedScene # 风火轮预制体
@export var item_count: int # 风火轮数量
@export var start_degree: float # 起始角度，逆时针为正，顺时针为负，单位为度
@export var radius: float # 旋转半径
@export var rotation_speed: float # 旋转速度
@export var counter_clockwise: bool # 旋转方向，false为顺时针，true为逆时针
