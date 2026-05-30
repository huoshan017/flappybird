class_name UniformlyVariedMotionSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([CUniformlyVariedMotion]).iterate([CUniformlyVariedMotion])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		return

	var s = entities.size()
	var c_motions = components[0]
	for i in s:
		var c_motion = c_motions[i] as CUniformlyVariedMotion
		if c_motion.basic_linear_velocity == Vector2.ZERO:
			continue

		var entity = entities[i]
		var node = entity as Node2D

		# 根据加速度调整速度
		c_motion.basic_linear_velocity += c_motion.acceleration * delta

		# 更新坐标
		node.position += c_motion.basic_linear_velocity * delta
		Signals.entity_update.emit(entity)