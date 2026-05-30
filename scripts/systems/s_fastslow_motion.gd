class_name FastSlowMotionSystem
extends System

class MotionInfo:
	var elapsed_time: float = 0.0 # 已经经过的时间
	var current_segment: int = 0 # 当前段索引
	var is_back: bool = false # 是否正在返回

var entity2motion: Dictionary[String, MotionInfo] = {} # 存储实体ID与快慢动作组件的映射关系，格式为 {entity_id: motion_component}

func query() -> QueryBuilder:
	return q.with_all([CFastSlowMotion]).iterate([CFastSlowMotion])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		return

	var s = entities.size()
	var c_motions = components[0]
	for i in s:
		var c_motion = c_motions[i] as CFastSlowMotion
		if c_motion.basic_linear_velocity == Vector2.ZERO or c_motion.segment_duration <= 0.0:
			continue

		var motion_info: MotionInfo = null
		var entity = entities[i]
		var node = entity as Node2D
		if not entity2motion.has(entity.id):
			motion_info = MotionInfo.new()
			entity2motion[entity.id] = motion_info
		else:
			motion_info = entity2motion[entity.id]
			if motion_info.elapsed_time >= c_motion.segment_duration:
				return

		var velocity: Vector2 = c_motion.basic_linear_velocity
		# 返回时速度相反
		if c_motion.is_loop and motion_info.is_back:
			velocity = -velocity

		# 根据当前段的速度因子调整速度
		var velocity_factor = c_motion.velocity_factor_list[motion_info.current_segment]
		if velocity_factor < 0:
			Loggie.error("velocity factor should be non-negative")
			return
		velocity *= velocity_factor

		# 更新坐标
		node.position += velocity * delta
		motion_info.elapsed_time += delta
		Signals.entity_update.emit(entity)

		# 判断是否需要切换到下一段
		if motion_info.elapsed_time >= c_motion.segment_duration:
			motion_info.elapsed_time = 0.0
			if not motion_info.is_back:
				if motion_info.current_segment+1 >= c_motion.velocity_factor_list.size():
					if c_motion.is_loop:
						motion_info.is_back = true
					else:
						motion_info.elapsed_time = c_motion.segment_duration # 保持在最后一段
				else:
					motion_info.current_segment += 1
			else:
				if not c_motion.is_loop:
					Loggie.error("no loop motion")
				motion_info.current_segment -= 1
				if motion_info.current_segment < 0:
					motion_info.is_back = false
					motion_info.current_segment = 0