@tool

class_name EBackground
extends TEntity

func on_ready() -> void:
	super.on_ready()

	var velocity = get_component(CVelocity)
	if not velocity:
		Loggie.error("EBackground missing CVelocity component")
		return

	# 把背景的速度设置为跟随角色水平速度
	velocity.velocity.x = Constants.CHARACTER_HORIZENTAL_SPEED
	Loggie.notice("EBackground set velocity to %s" % str(velocity.velocity))
