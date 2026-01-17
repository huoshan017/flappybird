class_name VisualWorld
extends Node

const v_bird = preload("res://prefabs/visual/v_bird.tscn")
const v_floor = preload("res://prefabs/visual/v_floor.tscn")
const v_pipe_up = preload("res://prefabs/visual/v_pipe_up.tscn")
const v_pipe_down = preload("res://prefabs/visual/v_pipe_down.tscn")
const v_entity_list = [
	v_bird,
	v_floor,
	v_pipe_up,
	v_pipe_down,
]

@onready var camera: Camera2D = $Camera2D
@onready var background: Control = $Background

# 讀取指定節點指定屬性
static func u_get_ventity_config(packed_scene: PackedScene, target_path: NodePath, property_name: String):
	var state = packed_scene.get_state()
	var node_count = state.get_node_count()
	
	for i in node_count:
		var node_path = state.get_node_path(i)
		if node_path == target_path:
			# 找到節點後找屬性
			var prop_count = state.get_node_property_count(i)
			for j in prop_count:
				if state.get_node_property_name(i, j) == property_name:
					return state.get_node_property_value(i, j)
	
	return null

# 從prefab中讀取實體類型ID
static func u_get_entity_type_id(data: PackedScene) -> int:
	var state = data.get_state()
	var node_count = state.get_node_count()

	for i in node_count:
		# 找到根節點後找type_id屬性
		var prop_count = state.get_node_property_count(i)
		for j in prop_count:
			if state.get_node_property_name(i, j) == "type_id":
				return int(state.get_node_property_value(i, j))
	return -1

# 可視化實體類型對應表
var ventity_prefabs: = {}

# 可視化實體實例對應表
var ventities_map: = {}

# 初始化可視化實體對應表
func u_init_visual_entity():
	for prefab in v_entity_list:
		var id = u_get_entity_type_id(prefab)
		ventity_prefabs[id] = prefab

# 初始化信號
func u_init_signals(world: World) -> void:
	world.entity_added.connect(on_add_visual_entity)
	world.entity_removed.connect(on_remove_visual_entity)
	Signals.entity_update.connect(on_update_visual_entity)
	Signals.entity_dead.connect(u_visual_entity_dead)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	u_init_visual_entity()
	var world = get_parent().get_node("World") as World
	u_init_signals(world)

func _process(delta: float) -> void:
	if Global.game_state == Enums.GameState.STATE_GAMEOVER or Global.game_state == Enums.GameState.STATE_PAUSED or Global.game_state == Enums.GameState.STATE_BEFORE_GAMEOVER:
		return
	camera.position.x += Constants.CHARACTER_HORIZENTAL_SPEED *delta
	background.position.x += Constants.CHARACTER_HORIZENTAL_SPEED * delta

# 添加可視化實體
func on_add_visual_entity(entity: TEntity) -> void:
	var type_id = entity.type_id
	if not ventity_prefabs.has(type_id):
		Loggie.error("No visual entity for type id: ", type_id)
		return
	
	if ventities_map.has(entity.id):
		Loggie.warn("Visual entity already exists for entity id: ", entity.id)
		return

	var ventity_prefab: PackedScene = ventity_prefabs[type_id]
	var ventity: TNode2D = ventity_prefab.instantiate() as TNode2D
	add_child(ventity)
	ventities_map[entity.id] = ventity
	on_update_visual_entity_(entity, ventity)
	ventity.play()

# 刪除可視化實體
func on_remove_visual_entity(entity: TEntity) -> void:
	if not ventities_map[entity.id]:
		Loggie.warn("No visual entity found for entity id: ", entity.id)
		return

	var ventity_instance = ventities_map[entity.id]
	remove_child(ventity_instance)
	ventities_map.erase(entity.id)

# 更新實體
func on_update_visual_entity(entity: TEntity) -> void:
	if not ventities_map.has(entity.id):
		Loggie.warn("No visual entity found for entity id: ", entity.id, ", add it")
		on_add_visual_entity(entity)
		return

	var ventity = ventities_map[entity.id]
	on_update_visual_entity_(entity, ventity)
	
# 更新實體內部函數
func on_update_visual_entity_(entity: TEntity, ventity: TNode2D) -> void:
	var entity_transform: CTransform = entity.get_component(CTransform)
	if entity_transform == null:
		Loggie.error("Entity id ", entity.id, " has no CTransform component, update failed")
		return

	ventity.position = entity_transform.position
	ventity.rotation_degrees = entity_transform.rotation

# 可視化實體死亡處理
func u_visual_entity_dead(entity: TEntity) -> void:
	if Global.is_player_entity(entity):
		# 玩家實體死亡，觸發遊戲結束信號
		var ventity = ventities_map[entity.id]
		ventity.stop()
