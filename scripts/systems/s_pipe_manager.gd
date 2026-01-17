class_name PipeManagerSystem
extends System

const pipe_up_prefab = preload("res://prefabs/entity/pipe_up.tscn")
const pipe_down_prefab = preload("res://prefabs/entity/pipe_down.tscn")

class pipe_data:
	var position: Vector2
	var up_or_down: bool = false
	func _init(pos: Vector2, uod: bool) -> void:
		position = pos
		up_or_down = uod

var pipe_datalist: Array[pipe_data] = [
	pipe_data.new(Vector2(400, 1000), true),
	pipe_data.new(Vector2(1000, 150), false),
	pipe_data.new(Vector2(1600, 1050), true),
	pipe_data.new(Vector2(2200, 100), false),
	pipe_data.new(Vector2(2800, 1000), true),
	pipe_data.new(Vector2(3400, 150), false),
	pipe_data.new(Vector2(4000, 1050), true),
	pipe_data.new(Vector2(4600, 100), false),
	pipe_data.new(Vector2(5200, 1000), true),
	pipe_data.new(Vector2(5800, 150), false),
	pipe_data.new(Vector2(6400, 1050), true),
	pipe_data.new(Vector2(7000, 100), false),
	pipe_data.new(Vector2(7600, 1000), true),
	pipe_data.new(Vector2(8200, 150), false),
	pipe_data.new(Vector2(8600, 1050), true),
	pipe_data.new(Vector2(9200, 100), false),
	pipe_data.new(Vector2(9800, 1000), true),
	pipe_data.new(Vector2(10400, 150), false),
]

var started: bool = false
var new_pipe_index: int = 0
var start_x: float = 0
var character: CharacterBody2D = null
var pipe_inst_list: Array[Node] = []
var pass_index: int = 0

func _ready() -> void:
	Signals.start_game.connect(on_start_game)
	Signals.game_over.connect(on_game_over)
	Loggie.notice("PipeManagerSystem ready")

func query() -> QueryBuilder:
	return q.with_all([CPipeID, CCollisionShapeObject, CTransform]).iterate([CCollisionShapeObject, CTransform])

func process(_entities: Array[Entity], _components: Array, _delta: float) -> void:
	if not started: return
	check_pass_through()
	if new_pipe_index >= pipe_datalist.size(): return
	var pd = pipe_datalist[new_pipe_index]
	if pd.position.x + start_x > character.position.x+600: return
	var pipe_inst: Node = null
	if pipe_datalist[new_pipe_index].up_or_down:
		pipe_inst = pipe_up_prefab.instantiate() 
	else:
		pipe_inst = pipe_down_prefab.instantiate()
	pipe_inst.position = Vector2(start_x + pd.position.x, pd.position.y)
	pipe_inst_list.append(pipe_inst)
	Signals.entity_added_to_scene.emit(pipe_inst as Entity)
	var transform: CTransform = (pipe_inst as Entity).get_component(CTransform) 
	transform.position = pipe_inst.position
	Signals.entity_update.emit(pipe_inst as TEntity)
	new_pipe_index += 1
	Loggie.notice("Spawn pipe at x: %f, y: %f" % [transform.position.x, transform.position.y])

func on_start_game():
	character = Global.player as Node as CharacterBody2D
	start_x = character.position.x
	started = true
	Loggie.notice("PipeManagerSystem started")

func on_game_over():
	started = false
	pipe_inst_list.clear()
	pass_index = 0
	new_pipe_index = 0
	Loggie.notice("PipeManagerSystem stopped")

func check_pass_through():
	if not started: return
	if pass_index >= pipe_inst_list.size(): return
	var pd = pipe_inst_list[pass_index]
	if character.position.x > pd.position.x+52: # 52 is pipe width / 2
		Signals.entity_pass_through.emit(pd as Entity)
		#Loggie.notice("Entity %s passed through pipe %d" % [str(pd.name), pass_index])
		pass_index += 1