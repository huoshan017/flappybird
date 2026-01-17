extends Node

var score: int = 0
var last_tick_msec: int
var data = {}
var file_path := "user://save_data.json"

func _ready() -> void: 
	Signals.entity_pass_through.connect(_on_pass_through)
	Signals.entity_dead.connect(_on_entity_dead)
	_load_data()
	
func _process(_delta: float) -> void:
	if last_tick_msec == 0:
		last_tick_msec = Time.get_ticks_msec()
	if Time.get_ticks_msec() - last_tick_msec >= 1000:
		#_save()
		last_tick_msec = Time.get_ticks_msec()

func _on_pass_through(_entity: Entity) -> void:
	score += 1
	Global.current_score = score
	#_save()
	Signals.score_update.emit(score)
	Loggie.notice("Score: %d" % score)

func _on_entity_dead(_entity: Entity) -> void:
	_save()

func _load_data() -> void:
	if not FileAccess.file_exists(file_path):
		Loggie.notice("No save data found, starting fresh.")
		data = {"max_score": 0}
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		Loggie.error("Failed to parse save data JSON")
		data = {"max_score": 0}
		return
	var js = json.data as Dictionary
	data.max_score = js.max_score
	Global.best_score = data.max_score
	Loggie.notice("Loaded Max Score: %d" % data.max_score)

func _save() -> void:
	if score > data.max_score:
		data.max_score = score
		_save_data()
		Loggie.notice("New Max Score: %d" % data.max_score)

func _save_data() -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		Loggie.error("无法打开保存文件进行写入")
		return
	var json_str = JSON.stringify(data)
	file.store_string(json_str)
	file.close()