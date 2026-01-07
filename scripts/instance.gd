class_name GameInstance
extends Node

enum InstanceState {
	STATE_NOT_STARTED, # 未开始
	STATE_PLAYING,	 # 游戏中
	STATE_PAUSED	# 暂停
}

@onready var visual_world: Node = $VisualWorld	
@onready var world: World = $World

var state: InstanceState = InstanceState.STATE_NOT_STARTED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ECS.world = world
	Signals.entity_added_to_scene.connect(on_entity_added_to_scene)
	Signals.entity_removed_from_scene.connect(on_entity_removed_from_scene)
	Signals.entity_collide.connect(on_entity_collide)
	Signals.entity_dead.connect(on_entity_dead)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	world.process(delta, 'Gameplay')

func _physics_process(delta: float) -> void:
	world.process(delta, 'Physics')
	
func start() -> void:
	state = InstanceState.STATE_PLAYING
	Signals.start_game.emit()

func stop() -> void:
	state = InstanceState.STATE_NOT_STARTED

func pause() -> void:
	state = InstanceState.STATE_PAUSED

func on_entity_added_to_scene(entity: Entity):
	world.add_entity(entity)

func on_entity_removed_from_scene(entity: Entity):
	world.remove_entity(entity)

func on_entity_dead(entity: Entity) -> void:
	if Global.is_player_entity(entity):
		stop()
		Signals.game_over.emit()

func on_entity_collide(_entity: Entity, _collider: Entity) -> void:
	Signals.before_game_over.emit()
