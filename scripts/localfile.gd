extends Node

var score: int = 0
var last_tick_msec: int
var data = {}
var file_path := "user://save_data.json"

func _ready() -> void: 
	Signals.entity_pass_through.connect(_on_pass_through)
	Signals.entity_dead.connect(_on_entity_dead)
	Signals.save_game_local.connect(_save)
	Signals.re_enter_game.connect(_on_re_enter_game)
	_load_data()
	
func _process(_delta: float) -> void:
	if last_tick_msec == 0:
		last_tick_msec = Time.get_ticks_msec()
	if Time.get_ticks_msec() - last_tick_msec >= 1000:
		last_tick_msec = Time.get_ticks_msec()

func _load_data() -> void:
	if not FileAccess.file_exists(file_path):
		Loggie.notice("No save data found, starting fresh.")
		# 没找到文件初始化新玩家信息
		data = { "best_score": 0, "player_id": Constants.DEFAULT_PLAYER_ID, "player_platform": Enums.PlayerPlatform.NONE, "saved_unix_ms": Global.get_unix_ms() }
		_save(true)
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		Loggie.error("Failed to parse save data JSON")
		data = {"best_score": 0}
		return
	var js = json.data as Dictionary
	data.best_score = js.best_score
	Global.best_score = data.best_score
	Loggie.notice("Loaded Best Score: %d" % data.best_score)

func _save(is_force: bool = false, to_remote: bool = false) -> void:
	if (not is_force and score > data.best_score) or is_force:
		var saved_ms = Global.get_unix_ms()
		Global.best_score = score
		Global.saved_game_ms = saved_ms
		data.best_score = score
		data.saved_unix_ms = saved_ms
		_save_data()
		Loggie.notice("New Best Score: %d" % data.best_score)
		var bytes = var_to_bytes(data)
		if to_remote:
			Signals.save_game_remote.emit(bytes)

func _save_data() -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		Loggie.error("无法打开保存文件进行写入")
		return
	var json_str = JSON.stringify(data)
	file.store_string(json_str)
	file.close()
	Loggie.notice("保存了游戏文件")

func _on_pass_through(_entity: Entity) -> void:
	score += 1
	Global.current_score = score
	Signals.score_update.emit(score)
	Loggie.notice("Score: %d" % score)

func _on_entity_dead(_entity: Entity) -> void:
	_save(false, true)

func _on_re_enter_game() -> void:
	score = 0