extends Node

enum LoginState {
	Not, Doing, Done,
}

var instance: GameInstance
var canvas_layer: CanvasLayer
var main_menu: Control
var ready_ui: Control
var paused_ui: Control
var gameover_ui: Control 
var score_ui: Control

var prev_state: Enums.GameState = Global.game_state
var login_state: LoginState = LoginState.Not

var curr_gameover_anim_y: float = 0.0
var is_gameover_anim_playing: bool = false
const gameover_anim_start_y: float = 1280.0
const gameover_anim_end_y: float = 0.0
const gameover_anim_speed: float = 2000.0

const logo_scene = preload("res://prefabs/ui/logo.tscn")
const main_menu_scene = preload("res://prefabs/ui/main_menu.tscn")
const ready_scene = preload("res://prefabs/ui/ready.tscn")
const paused_scene = preload("res://prefabs/ui/paused.tscn")
const gameover_scene = preload("res://prefabs/ui/game_over.tscn")
const instance_scene = preload("res://scenes/instance.tscn")
const score_scene = preload("res://prefabs/ui/score.tscn")

func _ready() -> void:
	Global.game_state = Enums.GameState.STATE_LOGO
	Signals.login_done.connect(_on_login_done)
	Signals.enter_game.connect(_on_enter_game)
	Signals.re_enter_game.connect(_on_re_enter_game)
	Signals.tap_play.connect(_on_tap_play)
	Signals.before_game_over.connect(_on_before_game_over)
	Signals.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
	if Global.game_state == prev_state:
		return

	if Global.game_state == Enums.GameState.STATE_LOGO:
		Global.game_state = Enums.GameState.STATE_LOGIN
	elif Global.game_state == Enums.GameState.STATE_LOGIN:
		_do_login()
	elif Global.game_state == Enums.GameState.STATE_MENU:
		_create_instance()
		if main_menu == null:
			main_menu = main_menu_scene.instantiate()
			canvas_layer.add_child(main_menu)
	elif Global.game_state == Enums.GameState.STATE_READY:
		if ready_ui == null:
			ready_ui = ready_scene.instantiate()
			canvas_layer.add_child(ready_ui)
		elif not ready_ui.visible:
			ready_ui.visible = true
	elif Global.game_state == Enums.GameState.STATE_GAMEPLAY:
		pass
	elif Global.game_state == Enums.GameState.STATE_PAUSED:
		if paused_ui == null:
			paused_ui = paused_scene.instantiate()
			canvas_layer.add_child(paused_ui)
		if not paused_ui.visible:
			paused_ui.visible = true
	elif Global.game_state == Enums.GameState.STATE_BEFORE_GAMEOVER:
		pass
	elif Global.game_state == Enums.GameState.STATE_GAMEOVER:
		if gameover_ui == null:
			gameover_ui = gameover_scene.instantiate()
			canvas_layer.add_child(gameover_ui)
		elif not gameover_ui.visible:
			gameover_ui.visible = true
		# 结算积分显示
		gameover_ui.best_score_tex._on_set_score(Global.best_score)
		gameover_ui.current_score_tex._on_set_score(Global.current_score)
		gameover_ui._set_medal(Global.current_score)
		_game_over_play_anim(delta)
	else:
		Loggie.error("Unknown game state: %s" % str(Global.game_state))

func _do_login():
	if login_state == LoginState.Not:
		login_state = LoginState.Doing
		Loggie.notice("login state doing")
		Signals.to_login_account.emit()
	elif login_state == LoginState.Done:
		Global.game_state = Enums.GameState.STATE_MENU
		Loggie.notice("game state transfer to MAINMENU")

func _on_login_done(_success: bool):
	login_state = LoginState.Done
	Loggie.notice("login state done")

func _on_enter_game() -> void:
	#canvas_layer.remove_child(main_menu)
	if Global.game_state != Enums.GameState.STATE_MENU:
		Loggie.warn("before enter game, GameState must be MENU")
	main_menu.visible = false
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_READY

func _on_re_enter_game() -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEOVER:
		Loggie.notice("before re-enter game, GameState must be GAMEOVER, but now is ", Global.game_state)
		return
	#canvas_layer.remove_child(gameover_ui)
	gameover_ui.visible = false
	instance.reset()
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_READY
	Loggie.notice("Re-enter game")

func _create_instance() -> void:
	if instance == null:
		instance = instance_scene.instantiate() as GameInstance
		add_child(instance)
	if canvas_layer == null:
		canvas_layer = instance.get_node("CanvasLayer") as CanvasLayer
	if score_ui == null:
		score_ui = score_scene.instantiate()
		canvas_layer.add_child(score_ui)

func _on_tap_play() -> void:
	if Global.game_state != Enums.GameState.STATE_READY:
		Loggie.warn("before tap to play, GameState must be READY, but now is ", Global.game_state)
		return
	ready_ui.visible = false
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_GAMEPLAY	
	instance.start()
	Loggie.notice("tap play")

func _on_before_game_over() -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		Loggie.warn("before enter before game over, GameState must be GAMEPLAY, but now is ", Global.game_state)
		return
	instance.pause()
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_BEFORE_GAMEOVER

func _on_game_over() -> void:
	if Global.game_state != Enums.GameState.STATE_BEFORE_GAMEOVER && Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		Loggie.warn("before enter game over, GameState must be BEFORE_GAMEOVER or GAMEPLAY, but now is ", Global.game_state)
		return
	instance.stop()
	prev_state = Global.game_state
	Global.game_state = Enums.GameState.STATE_GAMEOVER	
	_game_over_anim_start()
	Loggie.notice("game over started anim ")

func _game_over_anim_start() -> void:
	curr_gameover_anim_y = gameover_anim_start_y
	is_gameover_anim_playing = true
	Loggie.notice("game over start anim")

func _game_over_play_anim(delta: float) -> void:
	if not is_gameover_anim_playing:
		return
	curr_gameover_anim_y -= gameover_anim_speed * delta
	if curr_gameover_anim_y <= gameover_anim_end_y:
		curr_gameover_anim_y = gameover_anim_end_y
		is_gameover_anim_playing = false
	gameover_ui.position.y = curr_gameover_anim_y
