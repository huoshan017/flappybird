class_name Hud
extends Control

class StaminaBar extends Control:
	@onready var background_bar: ColorRect = $"BackgroundBar"
	@onready var stamina_bar: ColorRect = $"StaminaBar"

	const bar_width: float = 400.0
	const bar_height: float = 40.0
	# === 颜色配置 ===
	const color_full: Color = Color("#4ADE80")      # 绿色
	const color_medium: Color = Color("#FACC15")    # 黄色
	const color_low: Color = Color("#F87171")       # 红色
	const color_background: Color = Color("#1F2937")
	# === 闪烁配置 ===
	const blink_speed: float = 8.0
	const _blink_time: float = 0.0
	# === 视图状态 ===
	var is_blinking: bool = false
	var blink_intensity: float = 0.0

	func _init() -> void:
		background_bar.size = Vector2(bar_width, bar_height)
		background_bar.color = color_background
		stamina_bar.size = Vector2(bar_width, bar_height)
		stamina_bar.color = color_full