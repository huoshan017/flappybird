class_name PlayerMovementSystem
extends System

const JUMP_VELOCITY_Y: float = -500.0 # 跳跃时的初始速度
const JUMP_DURATION: float = 0.3 # 跳跃持续时间
const GRAVITY_ACCELERATION: float = 1500.0 # 重力加速度
const JUMP_ANGULAR_VELOCITY: float = -2475.0 # 跳跃时的角速度
const JUMP_ANGLE_LIMIT: float = -20.0 # 跳跃时的最大仰角

const MASS: float = 1.0 # 质量
const INERTIA: float = 40000.0 # 转动惯量(值越大越难转动)
const CENTER_OF_MASS_OFFSET: Vector2 = Vector2(50, 0) # 重心相对于旋转点(Node2D坐标)的偏移

# 旋转处理类
class RotationProcess:
	var is_jumping_: bool = false # 是否在跳跃
	var jump_time_: float = 0.0 # 跳跃持续时间计时器
	var angular_velocity_: float = 0.0

	func _init() -> void:
		reset()

	func reset()-> void:
		is_jumping_ = false
		jump_time_ = 0.0
		angular_velocity_ = 0.0

	func start_jump() -> bool:
		if is_jumping_:
			return false
		is_jumping_ = true
		jump_time_ = 0.0
		return true

	func update(transform: CTransform, character_body: CharacterBody2D, delta: float) -> void:
		if is_jumping_:
			jump_time_ += delta
			if jump_time_ >= JUMP_DURATION:
				is_jumping_ = false
			else:
				# 继续跳跃逻辑
				transform.rotation += JUMP_ANGULAR_VELOCITY * delta
				if transform.rotation < JUMP_ANGLE_LIMIT:
					transform.rotation = JUMP_ANGLE_LIMIT
					is_jumping_ = false
			# 当跳跃结束时，重置角速度
			if not is_jumping_:
				jump_time_ = 0.0
				angular_velocity_ = 0.0
		
		# 1. 计算重力在全局坐标下的向量
		var gravity_vector = Vector2(0, GRAVITY_ACCELERATION*MASS)

		# 2. 计算当前重心相对于旋转点的实时位置(考虑节点的当前旋转)
		# apply_scale(scale) 如果有缩放也需要考虑
		var r = CENTER_OF_MASS_OFFSET.rotated(deg_to_rad(transform.rotation))

		# 3. 计算力矩(二维中力矩=r.cross(F))
		# 在Godot中，Vector2的cross方法返回的是标量值，代表垂直于屏幕的角度力矩
		var torque = r.cross(gravity_vector)

		# 4. 计算角加速度(α=torque/I)
		var angular_acceleration = torque / INERTIA

		# 5. 更新角速度
		angular_velocity_ += angular_acceleration * delta

		# 6. 更新旋转角度
		transform.rotation += rad_to_deg(angular_velocity_ * delta)

		if transform.rotation > 90.0:
			transform.rotation = 90.0

		character_body.rotation_degrees = transform.rotation

# 旋转处理器成员
var rotation_process: RotationProcess

# 是否碰撞后正在掉落
var is_falling_after_collision: bool = false

# 过滤条件
func query() -> QueryBuilder:
	return q.with_all([CInput, CCollisionShapeObject, CVelocity, CTransform]).iterate([CCollisionShapeObject, CVelocity, CTransform])

# 物理更新，不用delta，使用固定的时间步长
func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	if Global.game_state == Enums.GameState.STATE_GAMEOVER or Global.game_state == Enums.GameState.STATE_PAUSED:
		return

	if entities.size() == 0:
		return

	var entity = entities[0]
	if entity == null:
		return

	var velocity = entity.get_component(CVelocity)
	var collision_obj = entity.get_component(CCollisionShapeObject)
	var character_body: CharacterBody2D = collision_obj.collision_obj_ as CharacterBody2D
	var transform = entity.get_component(CTransform)

	if rotation_process == null:
		rotation_process = RotationProcess.new()

	# 游戏中和游戏结束前状态都受到重力影响
	if Global.game_state == Enums.GameState.STATE_GAMEPLAY or Global.game_state == Enums.GameState.STATE_BEFORE_GAMEOVER:
		# 这里的游戏状态是指玩家可以输入操作的状态，此时才可以跳跃且受到重力的影响
		if Global.game_state == Enums.GameState.STATE_GAMEPLAY:
			var input = entity.get_component(CInput)
			var isj = input.is_jumping()
			if isj:
				velocity.velocity.y = JUMP_VELOCITY_Y
				if rotation_process.start_jump():
					Signals.entity_flapped.emit(entity) # 发出拍打信号
		velocity.velocity.y += GRAVITY_ACCELERATION*delta # 重力加速度
		rotation_process.update(transform, character_body, delta)

	var motion = velocity.velocity * delta
	# 在游戏结束前状态，角色不再水平移动
	if Global.game_state == Enums.GameState.STATE_BEFORE_GAMEOVER:
		motion.x = 0
	var collision = character_body.move_and_collide(motion, true)
	if collision:
		var collider = collision.get_collider() as TEntity
		# 碰到地面，触发实体死亡信号
		if Global.is_floor_entity(collider):
			var collider_transform = collider.get_component(CTransform)
			Loggie.notice("!!!! collider position: (x:%f y:%f), character_body position: (x:%f, y:%f)" % [collider_transform.position.x, collider_transform.position.y, character_body.position.x, character_body.position.y]) 
			transform.position = character_body.position
			is_falling_after_collision = false
			Signals.entity_dead.emit(entity)
		else:
			# 处理碰撞逻辑
			if is_falling_after_collision == false:
				is_falling_after_collision = true
				Signals.entity_collide.emit(entity, collider)
				#Loggie.notice("Player start falling after collision")
			else: # 碰到其他物体，继续下落
				character_body.position += motion
				transform.position = character_body.position
				#Loggie.notice("Player position updated while falling: (x:%f y:%f)" % [transform.position.x, transform.position.y])
	else:
		character_body.position += motion
		transform.position = character_body.position
		#Loggie.notice("Player position updated: (x:%f y:%f) no collide" % [transform.position.x, transform.position.y])

	Signals.entity_update.emit(entity)
