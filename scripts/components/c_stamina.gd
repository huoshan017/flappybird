# 体力组件

class_name CStamina
extends Component

# 体力状态
enum StaminaState {
	Normal,
	Exhausted,
}

var current_stamina: float = 0.0
@export var max_stamina: float = 100.0

# === 消耗恢复参数 ===
var depletion_rate: float = 25.0      # 每秒消耗
var recovery_rate: float = 10.0       # 每秒恢复
var recover_threshold: float = 30.0   # 恢复使用的阈值
# === 状态标志 ===
var can_use: bool = true
var is_exhausted: bool = false
var is_low_warning: bool = false
# === 低体力阈值（百分比） ===
var low_warning_percent: float = 20.0

func _init() -> void:
	current_stamina = max_stamina

# === 只读属性 ===
func get_ratio() -> float:
	return current_stamina / max_stamina if max_stamina > 0 else 0.0

func get_percentage() -> float:
	return get_ratio() * 100.0

func is_empty() -> bool:
	return current_stamina <= 0.0

func is_full() -> bool:
	return current_stamina >= max_stamina

# === 体力操作 ===
func consume(amount: float) -> void:
	current_stamina = max(0.0, current_stamina - amount)
	if current_stamina <= 0.0:
		current_stamina = 0.0
		is_exhausted = true
		can_use = false

func recover(amount: float) -> void:
	current_stamina = min(max_stamina, current_stamina + amount)
	if is_exhausted and not can_use and current_stamina >= recover_threshold:
		is_exhausted = false
		can_use = true

func update_state() -> void:
	is_low_warning = get_percentage() < low_warning_percent