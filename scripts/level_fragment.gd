@tool

class_name LevelFragment
extends Node2D

@export var width: int = 720:
	set(v):
		width = v
		queue_redraw()

@export var height: int = 1280:
	set(v):
		height = v
		queue_redraw()

@export var debug_color: Color = Color(0, 1, 1, 0.5)

func _draw() -> void:
	# 只有在编辑器模式下才绘制，避免干扰实际游戏画面
	if Engine.is_editor_hint():
		var rect = Rect2(Vector2.ZERO, Vector2(width, height))
		
		# 绘制一个空心矩形边框，线宽为 4
		draw_rect(rect, debug_color, false, 4.0)
		
		# 可选：绘制一个填充的半透明背景，方便识别范围
		# draw_rect(rect, Color(debug_color, 0.1), true)