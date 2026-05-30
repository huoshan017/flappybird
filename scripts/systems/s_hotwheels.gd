class_name HotWheelsSystem
extends System

var id2items = {} # 存储实体ID与风火轮实例的映射关系，格式为 {entity_id: [item_instance1, item_instance2, ...]}

func query() -> QueryBuilder:
	return q.with_all([CHotWheels]).iterate([CHotWheels])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		return

	var s = entities.size()
	var c_hotwheels = components[0]
	for i in s:
		var c_hotwheel = c_hotwheels[i] as CHotWheels
		if c_hotwheel.item == null or c_hotwheel.item_count <= 0 or c_hotwheel.radius <= 0 or c_hotwheel.rotation_speed == 0:
			continue
		
		var offset = Vector2(c_hotwheel.radius, 0)
		offset = offset.rotated(deg_to_rad(deg_to_rad(c_hotwheel.start_degree))) # 根据起始角度旋转偏移量，确定第一个风火轮的位置
		var entity = entities[i]
		if not id2items.has(entity.id):
			id2items[entity.id] = []
			for j in c_hotwheel.item_count:
				var item_instance = c_hotwheel.item.instantiate() as Node2D
				entity.add_child(item_instance)
				id2items[entity.id].append(item_instance)
				var delta_angle = deg_to_rad(360.0 / c_hotwheel.item_count)
				if c_hotwheel.counter_clockwise:
					delta_angle = -delta_angle
				item_instance.position = offset.rotated(delta_angle*j) # 初始位置，均匀分布在圆周上，这里风火轮的坐标是相对于中心点entity的，所以直接设置为偏移量即可
				Signals.entity_added_to_world.emit(item_instance) # 发出信号，通知其他系统有新的实体添加到世界中
		else:
			for j in c_hotwheel.item_count:
				var item_instance = id2items[entity.id][j]
				var angle = c_hotwheel.rotation_speed * delta
				var radians = deg_to_rad(angle)
				if c_hotwheel.counter_clockwise:
					radians = -radians
				item_instance.position = item_instance.position.rotated(radians) # 更新位置，保持在圆周上旋转 
				Signals.entity_update.emit(item_instance) # 发出信号，通知其他系统实体发生了更新
