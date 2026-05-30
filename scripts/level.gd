extends Node

# 关卡管理器，负责管理关卡碎片的加载和卸载
# 关卡碎片分为两种：普通关卡碎片和链接关卡碎片。普通关卡碎片只包含一个场景，而链接关卡碎片包含一个场景和一个指向下一个关卡碎片的链接。
# 默认关卡碎片的宽高为720x1280，可以通过编辑器调整。关卡碎片的加载和卸载由check_time_ms控制，每0.05秒检查一次当前视口的位置，根据位置加载或卸载相应的关卡碎片。
# 关卡碎片的场景可以通过编辑器指定，关卡碎片的链接可以通过编辑器指定。当玩家进入一个链接关卡碎片时，自动加载下一个关卡碎片，并将当前关卡碎片卸载。
# 关卡碎片的场景可以包含任何内容，例如地形、障碍物、敌人等。关卡碎片的链接可以实现无缝连接不同的关卡碎片，形成一个完整的关卡。
# 目前只处理从左向右的场景碎片加载和卸载，后续可以根据需要添加从右向左、从上向下的场景碎片加载和卸载。

@export var width: int = 720
@export var height: int = 1280
@export var level_fragments: Array[PackedScene] = []
@export var linked_level_fragment: PackedScene

var current_fragment_index: int = -1 # 当前加载的关卡碎片索引，初始值为-1表示没有加载任何关卡碎片
var left_border: float = 0 # 相机位置所在的关卡碎片的左边界位置，单位为像素
var right_border: float = 0 # 相机位置所在的关卡碎片的右边界位置，单位为像素
var curr_camera_pos: Vector2 = Vector2.ZERO # 当前相机位置，初始值为(0, 0)
var index2fragment_inst: Dictionary[int, LevelFragment] = {} # 关卡碎片索引到加载碎片实例的映射

func _ready() -> void:
	left_border = 0
	right_border = width
	Signals.camera_move.connect(_on_camera_move)

func _on_camera_move(camera_pos: Vector2) -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		curr_camera_pos = camera_pos
		# 在主菜单或者准备界面时，因为角色一直在往右移动，所以要更新左右边界的位置
		if Global.game_state == Enums.GameState.STATE_MENU or Global.game_state == Enums.GameState.STATE_READY:
			left_border = camera_pos.x - width / 2.0
			right_border = left_border + width
		return

	var camera_right = camera_pos.x + width / 2.0
	var has_next_fragment = index2fragment_inst.has(current_fragment_index + 1)
	# 当相机右边界超过当前关卡碎片的中点时，加载下一个关卡碎片
	if camera_right >= (left_border + right_border) / 2.0 and current_fragment_index < level_fragments.size() - 1 and not has_next_fragment:
		# 加载下一个关卡碎片
		_load_fragment(current_fragment_index + 1)

	# 当上一帧相机位置小于关卡碎片的右边界且当前帧相机位置大于关卡碎片有边界时，更新碎片的左右边界
	if curr_camera_pos.x < right_border and camera_pos.x >= right_border and has_next_fragment:
		# 更新当前关卡碎片
		if current_fragment_index < 0:
			left_border =  camera_pos.x - width / 2.0
		else:
			left_border = right_border
		current_fragment_index += 1
		var next_fragment = index2fragment_inst[current_fragment_index]
		right_border = left_border + next_fragment.width
		index2fragment_inst.erase(current_fragment_index)
		next_fragment.queue_free()
	
	curr_camera_pos = camera_pos

# 加载关卡碎片
func _load_fragment(index: int) -> void:
	if index < 0 || index >= level_fragments.size():
		return
	#Loggie.notice("!!!!!! fragment index: ", index)
	var fragment = level_fragments[index]
	var fragment_inst = fragment.instantiate() as LevelFragment 
	fragment_inst.position.x = right_border
	#add_child(fragment_inst)
	index2fragment_inst[index] = fragment_inst
	var child_entities = fragment_inst.get_children()
	for child in child_entities:
		if child is Node2D and child is Entity:
			child.owner = null
			#var old_position = child.position
			#Loggie.notice("child node old position ", old_position)

			# child在reparent过程中会丢失物理同步，所以需要先关闭物理同步，等reparent完成后再打开物理同步
			var animatable_child: AnimatableBody2D
			var global_pos: Vector2
			if child is AnimatableBody2D and child.sync_to_physics:
				animatable_child = child
				animatable_child.sync_to_physics = false
				animatable_child.visible = false
				global_pos = animatable_child.global_position
				# 1. 强制重置物理插值，告诉引擎：不要平滑过渡，这是瞬移
				#animatable_child.reset_physics_interpolation()
			child.reparent(self)
			#Loggie.notice("child node old position ", old_position, " after reparent")
			#Loggie.notice("child node position ", child.position, ", right_border: ", right_border, ", fragment_inst position: ", fragment_inst.position)
			if animatable_child != null:
				# 3. 手动转换坐标并赋值
				animatable_child.global_position = global_pos
				await get_tree().physics_frame
				# 4. 再次强制重置，确保物理服务器认为当前位置就是“起始位置”
				animatable_child.reset_physics_interpolation()
				animatable_child.sync_to_physics = true
				animatable_child.visible = true
			Signals.entity_added_to_world.emit(child)

func _load_fragment2(index: int) -> void:
	if index < 0 || index >= level_fragments.size():
		return
	Loggie.notice("!!!!!! fragment index: ", index)
	var fragment_inst = level_fragments[index].instantiate() as LevelFragment
	fragment_inst.position.x = right_border
	index2fragment_inst[index] = fragment_inst
	var child_entities = fragment_inst.get_children()
	for child in child_entities:
		if child is Node2D and child is Entity:
			child.owner = null
			# 记录它在子场景里的原始相对位置
			var relative_pos = child.position
			Loggie.notice("child node old position ", relative_pos)
			# 2. 脱离原场景（此时它还在内存里，还没进物理世界）
			fragment_inst.remove_child(child)
			# 3. 加入当前场景（self 应该是关卡根节点或容器）
			add_child(child) 
			# 4. 计算并设置新坐标：右边界 + 偏移
			child.global_position.x = relative_pos.x + right_border 
			Loggie.notice("child node old position ", relative_pos, " after reparent")
			Loggie.notice("child node global_position ", child.global_position, ", right_border: ", right_border, ", fragment_inst position: ", fragment_inst.position)
			# 5. 针对 AnimatableBody2D 的关键处理
			if child is AnimatableBody2D:
				# 强制让渲染层立刻对齐物理层
				child.force_update_transform()
				# 抹除从 (0,0) 或 内存初始位 到当前位的插值记录
				child.reset_physics_interpolation()
			Signals.entity_added_to_world.emit(child)