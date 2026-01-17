extends Node

var instance: GameInstance
var canvas_layer: CanvasLayer
var main_menu: Node
var is_show_main_menu: bool = false
var ready_ui: Node
var is_show_ready_ui: bool = false
var paused_ui: Node
var is_show_pause_ui: bool = false
var gameover_ui: Control 
var is_show_gameover_ui: bool = false
var score_ui: Node

var prev_state: Enums.GameState = Global.game_state

var curr_gameover_anim_y: float = 0.0
var is_gameover_anim_playing: bool = false
const gameover_anim_start_y: float = 1280.0
const gameover_anim_end_y: float = 0.0
const gameover_anim_speed: float = 2000.0

func _ready() -> void:
	Global.game_state = Enums.GameState.STATE_MENU
	Signals.enter_game.connect(_on_enter_game)
	Signals.re_enter_game.connect(_on_re_enter_game)
	Signals.tap_play.connect(_on_tap_play)
	Signals.before_game_over.connect(_on_before_game_over)
	Signals.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
	if Global.game_state == prev_state:
		return

	if Global.game_state == Enums.GameState.STATE_MENU:
		_create_instance()
		if main_menu == null:
			main_menu = preload("res://prefabs/ui/main_menu.tscn").instantiate()
		if not is_show_main_menu:
			canvas_layer.add_child(main_menu)
			is_show_main_menu = true
	elif Global.game_state == Enums.GameState.STATE_READY:
		if ready_ui == null:
			ready_ui = preload("res://prefabs/ui/ready.tscn").instantiate()
		if not is_show_ready_ui:
			canvas_layer.add_child(ready_ui)
			is_show_ready_ui = true
	elif Global.game_state == Enums.GameState.STATE_GAMEPLAY:
		_create_instance()
	elif Global.game_state == Enums.GameState.STATE_PAUSED:
		if paused_ui == null:
			paused_ui = preload("res://prefabs/ui/paused.tscn").instantiate()
		if not is_show_pause_ui:
			canvas_layer.add_child(paused_ui)
			is_show_pause_ui = true
	elif Global.game_state == Enums.GameState.STATE_BEFORE_GAMEOVER:
		pass
	elif Global.game_state == Enums.GameState.STATE_GAMEOVER:
		if gameover_ui == null:
			gameover_ui = preload("res://prefabs/ui/game_over.tscn").instantiate()
		if not is_show_gameover_ui:
			canvas_layer.add_child(gameover_ui)
			is_show_gameover_ui = true
		gameover_ui.best_score_tex._on_set_score(Global.best_score)
		gameover_ui.current_score_tex._on_set_score(Global.current_score)
		_game_over_play_anim(delta)
	else:
		Loggie.error("Unknown game state: %s" % str(Global.game_state))

func _on_enter_game() -> void:
	canvas_layer.remove_child(main_menu)
	is_show_main_menu = false
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_READY

func _on_re_enter_game() -> void:
	canvas_layer.remove_child(gameover_ui)
	is_show_gameover_ui = false
	instance.free()
	instance = null
	score_ui = null
	_create_instance()
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_READY
	Loggie.notice("Re-enter game")

func _create_instance() -> void:
	if instance == null:
		instance = preload("res://scenes/instance.tscn").instantiate() as GameInstance
		add_child(instance)
	if canvas_layer == null:
		canvas_layer = instance.get_node("CanvasLayer") as CanvasLayer
	if score_ui == null:
		score_ui = preload("res://prefabs/ui/score.tscn").instantiate()
		canvas_layer.add_child(score_ui)

func _on_tap_play() -> void:
	canvas_layer.remove_child(ready_ui)
	is_show_ready_ui = false
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_GAMEPLAY	
	instance.start()

func _on_before_game_over() -> void:
	instance.pause()
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_BEFORE_GAMEOVER

func _on_game_over() -> void:
	instance.stop()
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_GAMEOVER	
	_game_over_anim_start()

func _game_over_anim_start() -> void:
	curr_gameover_anim_y = gameover_anim_start_y
	is_gameover_anim_playing = true

func _game_over_play_anim(delta: float) -> void:
	if not is_gameover_anim_playing:
		return
	curr_gameover_anim_y -= gameover_anim_speed * delta
	if curr_gameover_anim_y <= gameover_anim_end_y:
		curr_gameover_anim_y = gameover_anim_end_y
		is_gameover_anim_playing = false
	gameover_ui.position.y = curr_gameover_anim_y
