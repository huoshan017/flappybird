@tool

class_name EBackground
extends TEntity

func on_ready() -> void:
	var transform = get_component(CTransform)
	if not transform:
		Loggie.error("EBackground missing CTransform component")
		return

	# 说明设置了初始位置
	if transform.position != Vector2.ZERO:
		var node2d = self as Node as Node2D
		node2d.position = transform.position

	var velocity = get_component(CVelocity)
	if not velocity:
		Loggie.error("EBackground missing CVelocity component")
		return

	# 把背景的速度设置为跟随角色水平速度
	velocity.velocity.x = Constants.CHARACTER_HORIZENTAL_SPEED
	Loggie.notice("EBackground set velocity to %s" % str(velocity.velocity))
