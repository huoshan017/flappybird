extends Node

### 本地存档 ###
# 1. 默认存档："user://save_data.sav"
#    第一次进入游戏时必须要在本地创建的存档文件，如果没有网络或者玩家没有登陆账号则游戏进度数据只能存入该文件
#    也就是说作为纯单机游玩时的游戏存档，文件名不跟任何账号产生关联
# 2. 账号关联存档："user://save_<player_id>.sav"
#    玩家登陆账号后会根据玩家 ID 生成对应的存档文件名
#    该存档文件优先级高于默认存档文件

const DEFAULT_SAVE_FILE_PATH:= "user://save_data.sav"
const SAVE_FILE_FORMAT_PATH := "user://save_%s.sav"

var score_: int = 0
var last_tick_msec_: int
var data_: Structure.UserSaveData = Structure.UserSaveData.new()

func _get_save_file_path(player_id: String) -> String:
	var save_path: String
	if player_id == "" or player_id == Constants.DEFAULT_PLAYER_ID:
		save_path = DEFAULT_SAVE_FILE_PATH
	else:
		save_path = SAVE_FILE_FORMAT_PATH % player_id
	return save_path

func _ready() -> void: 
	Signals.to_load_game_local_save.connect(_on_load_save_data)
	Signals.entity_pass_through.connect(_on_pass_through)
	Signals.entity_dead.connect(_on_entity_dead)
	Signals.save_game_local.connect(_save)
	Signals.re_enter_game.connect(_on_re_enter_game)
	#_load_data()
	
func _process(_delta: float) -> void:
	if last_tick_msec_ == 0:
		last_tick_msec_ = Time.get_ticks_msec()
	if Time.get_ticks_msec() - last_tick_msec_ >= 1000:
		last_tick_msec_ = Time.get_ticks_msec()

func _on_load_save_data(player_id: String) -> void:
	if player_id == "": Global.player_id = Constants.DEFAULT_PLAYER_ID
	else: Global.player_id = player_id
	var save_path = _get_save_file_path(Global.player_id)

	# 玩家第一次进入游戏存档的时候必须要生成默认的存档文件
	# 是为了解决没有网络或者玩家没有登陆账号的情况下也能正常存档
	# 之后再进入游戏就不会有找不到默认存档的问题了
	if not FileAccess.file_exists(save_path):
		Loggie.notice("No save data found, starting fresh.")
		# 没找到存档文件初始化新玩家信息并保存
		data_.player_id = Global.player_id
		_save(data_.player_id, true)
	else:
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file != null:
			var buffer = file.get_buffer(file.get_length())
			data_.deserialize(buffer)
			file.close()
			# 默认存档中的玩家ID不是默认ID的话说明是有账号关联的存档
			if Global.player_id == Constants.DEFAULT_PLAYER_ID and (data_.player_id != Constants.DEFAULT_PLAYER_ID or data_.player_id != ""):
				var player_save_path = _get_save_file_path(data_.player_id)
				if not FileAccess.file_exists(player_save_path):
					# 正常情况下应该有这个文件
					Loggie.error("Expected player save file not found: %s" % player_save_path)
					return
				# 读取账号关联存档文件，读取数据到 data_
				file = FileAccess.open(player_save_path, FileAccess.READ)
				if file != null:
					buffer = file.get_buffer(file.get_length())
					data_.deserialize(buffer)
					file.close()
				else:
					var err = FileAccess.get_open_error()
					Loggie.error("无法打开保存文件进行读取%s, 错误码：%d" % [player_save_path, err])
					return
			Global.best_score = data_.best_score
			Loggie.notice("Loaded Best Score: %d" % data_.best_score)
		else:
			var err = FileAccess.get_open_error()
			Loggie.error("无法打开保存文件进行读取%s, 错误码：%d" % [save_path, err])
			return
	
	# 当前存档不是默认存档的话，还需要创建或者更新默认存档文件
	if save_path != DEFAULT_SAVE_FILE_PATH:
		var file: FileAccess = null
		var need_write: bool = false
		if not FileAccess.file_exists(DEFAULT_SAVE_FILE_PATH):
			file = FileAccess.open(DEFAULT_SAVE_FILE_PATH, FileAccess.WRITE)
			if file != null:
				need_write = true
				Loggie.notice("Created default save file for new player.")
			else:
				var err = FileAccess.get_open_error()
				Loggie.error("无法打开保存文件进行写入%s" % save_path % ", 错误码：%d" % err)
		else:
			file = FileAccess.open(DEFAULT_SAVE_FILE_PATH, FileAccess.WRITE_READ)
			if file != null:
				var buffer = file.get_buffer(file.get_length())
				var default_data = Structure.UserSaveData.new()
				default_data.deserialize(buffer)
				# 默认的存档不是当前账号的数据则需要更新成当前账号
				if default_data.player_id == Constants.DEFAULT_PLAYER_ID:
					# 默认账号比当前账号分数高则更新当前账号
					if default_data.best_score > data_.best_score:
						data_.best_score = default_data.best_score
					else:
						need_write = true
				elif default_data.player_id != Global.player_id:
					need_write = true
				# 把当前的存档数据写入默认存档文件
				if need_write:
					var bytes = data_.serialize(true)
					file.store_buffer(bytes)
					Loggie.notice("Default save file updated for new player.")
				file.close()
			else:
				var err = FileAccess.get_open_error()
				Loggie.error("无法打开默认存档文件%s进行写入, 错误码：%d", DEFAULT_SAVE_FILE_PATH, err)

	# 通知存档加载完成
	Signals.load_game_local_save_done.emit()

func _save(player_id: String, is_force: bool = false, to_remote: bool = false) -> void:
	if (not is_force and score_ > data_.best_score) or is_force:
		data_.best_score = score_
		Global.best_score = score_
		var bytes = _save_data(player_id)
		if bytes.size() == 0:
			Loggie.error("保存游戏数据失败")
			return
		Loggie.notice("New Best Score: %d" % data_.best_score)
		if to_remote and Global.is_authenticated:
			Signals.save_game_remote.emit(bytes, data_)

# 保存数据到本地文件，返回保存的字节数组
func _save_data(player_id: String) -> PackedByteArray:
	var save_path = _get_save_file_path(player_id)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var err = FileAccess.get_open_error()
		Loggie.error("无法打开保存文件进行写入%s" % save_path % ", 错误码：%d" % err)
		return PackedByteArray()
	var bytes = data_.serialize(true)
	file.store_buffer(bytes)
	file.close()
	Global.saved_game_ms = data_.saved_unix_ms
	Loggie.notice("保存了游戏文件")
	# 如果是账号关联存档，则同步一份到默认存档文件
	#if save_path != DEFAULT_SAVE_FILE_PATH:
	#	if not FileAccess.file_exists(DEFAULT_SAVE_FILE_PATH):
	#		var dir = DirAccess.open("user://")
	#		if dir == null:
	#			Loggie.error("无法打开存档目录进行复制默认存档文件, 错误码 %d" % DirAccess.get_open_error())
	#		else:
	#			dir.copy(save_path, DEFAULT_SAVE_FILE_PATH)
	#	else:
	#		file = FileAccess.open(DEFAULT_SAVE_FILE_PATH, FileAccess.WRITE)
	#		if file == null:
	#			var err = FileAccess.get_open_error()
	#			Loggie.error("无法打开默认存档文件%s进行写入, 错误码：%d", DEFAULT_SAVE_FILE_PATH, err)
	#		else:
	#			file.store_buffer(bytes)
	#			file.close()
	#			Loggie.notice("同步了默认存档文件")
	return bytes

func _on_pass_through(_entity: Entity) -> void:
	score_ += 1
	Global.current_score = score_
	Signals.score_update.emit(score_)
	Loggie.notice("Score: %d" % score_)

func _on_entity_dead(_entity: Entity) -> void:
	_save(Global.player_id, false, true)

func _on_re_enter_game() -> void:
	score_ = 0