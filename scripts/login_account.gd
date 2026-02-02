extends Node

### 账号登陆流程 ###
# 1. 检查当前平台是否支持 Google Play Games Services 插件
# 2. 如果支持则尝试静默登录
# 3. 登录成功后获取玩家信息
# 4. 载入云存档数据
# 5. 如果云存档数据不存在则使用本地存档数据
# 6. 登录完成后发送信号通知其他系统

const SAVED_GAME_NAME = "flappy_saved_game"
const SCORE_LEADERBOARD_ID = "CgkI7fWnlKgUEAIQAQ"

# 定义插件单例名称，方便后续调用
var play_services = null

# 玩家数据
var player_data_: PlayGamesPlayer

# 保存游戏数据结构
var save_data_: Structure.UserSaveData = Structure.UserSaveData.new()

func _ready():
	# 准备登陆账号的信号
	Signals.to_login_account.connect(_on_to_login_account)
	# 本地存档加载完成信号，用于等待本地存档加载完成后再继续登录流程
	Signals.load_game_local_save_done.connect(_on_load_game_local_save_done)
	# 保存本地文件功能发送过来的信号，用于请求保存游戏数据到云端
	Signals.save_game_remote.connect(_on_game_save_to_remote)
	# 最高分排行榜
	Signals.show_leaderboard.connect(_on_show_leaderboard)

# 等待加载本地存档完成和登录完成后再继续
#func _wait_load_save_done_and_login_done(player_id: String, login_success: bool) -> void:
#	Signals.to_load_game_local_save.emit(player_id)
#	await Signals.load_game_local_save_done
#	Signals.login_done.emit(login_success)

func _on_to_login_account() -> void:
	# 1. 检查插件是否在 Android 环境下可用
	var can_to_login = false
	var os_name = OS.get_name()
	if os_name == "Android":
		Global.player_platform = Enums.PlayerPlatform.STOCK_ANDROID
		if Engine.has_singleton("GodotPlayGameServices"):
			play_services = Engine.get_singleton("GodotPlayGameServices") 
			if play_services == null:
				Loggie.error("错误：无法获取 GodotPlayGameServices 单例")
			else:
				can_to_login = true
				_connect_signals()
				Loggie.notice("Google Play Services 插件已加载")
				# 2. 自动尝试静默登录
				# 用户如果之前登录过，这次不会弹出任何窗口
				login()
		else:
			Loggie.error("错误：已在 Android 运行但未发现插件，请检查导出设置中的 Plugins 勾选状态")
	else:
		Loggie.notice("当前平台%s没有登陆功能" % os_name)
	
	if not can_to_login:		
		Signals.to_load_game_local_save.emit("")
		#_wait_load_save_done_and_login_done("", can_to_login)

# 连接插件返回的信号
func _connect_signals():
	# 登录成功与否的信号
	play_services.userAuthenticated.connect(_on_user_authenticated)
	# 获取玩家信息的信号
	play_services.currentPlayerLoaded.connect(_on_player_info_loaded)
	# 载入游戏云存档完成的信号
	play_services.gameLoaded.connect(_on_game_loaded_from_remote)
	# 保存游戏云存档完成的信号
	play_services.gameSaved.connect(_on_game_saved_to_remote)
	# 冲突触发信号
	play_services.conflictEmitted.connect(_on_conflict_emitted)
	# 排行榜提交完成信号
	play_services.scoreSubmitted.connect(_on_score_submitted)
	# scoreLoaded信号
	play_services.scoreLoaded.connect(_on_score_loaded)

# 调用登录逻辑
func login():
	Loggie.notice("开始验证身份...")
	play_services.call("signIn")

# --- 信号回调处理 ---

func _on_user_authenticated(is_authenticated: bool):
	if is_authenticated:
		Loggie.notice("登录成功！用户已授权。")
		# 登录成功后，通常接着获取玩家昵称或 ID
		play_services.call("loadCurrentPlayer", false)
	else:
		Signals.to_load_game_local_save.emit("")
		#_wait_load_save_done_and_login_done("", false)
		Loggie.notice("登录失败：用户未授权或已登出。")
		Loggie.notice("使用本地存储的数据")

func _on_player_info_loaded(player_info: String):
	# player_info 包含: display_name, player_id, icon_image_uri 等
	var data = JSON.parse_string(player_info)
	player_data_ = PlayGamesPlayer.new(data)
	if Global.player_id != player_data_.player_id:
		Global.player_id = player_data_.player_id
	Loggie.notice("欢迎回来: " + data.displayName)
	Loggie.notice("玩家 ID: " + data.playerId)
	Loggie.notice("playerInfo: " + player_info)
	play_services.call("loadGame", SAVED_GAME_NAME, false)
	Loggie.notice("准备载入游戏云存档")

func _on_game_loaded_from_remote(json_data: String):
	var json := JSON.new()
	var err := json.parse(json_data)

	if err != OK:
		Loggie.warn("JSON 解析失败: %s (line %d)" % [
			json.get_error_message(),
			json.get_error_line()
			])
		return

	var snapshot = json.data #as PlayGamesSnapshot
	if snapshot != null:
		Loggie.notice("snapshot: content ", snapshot["content"])  # player
		Loggie.notice("snapshot: metadata ", snapshot["metadata"]) # 10

	# 还没有保存到云端
	if snapshot == null or snapshot.content == null or snapshot.content.is_empty():
		Signals.save_game_local.emit(player_data_.player_id, true, false)
		Loggie.notice("没有游戏云存档, 把player_id ", player_data_.player_id, " 保存到了本地存档里")
	else:
		if !save_data_.deserialize(snapshot.content):
			play_services.call("deleteSnapshot", snapshot.metadata.snapshotId)
			Loggie.error("无法识别的云存档数据类型: " + str(save_data_), ", 已删除该云存档")
			#_wait_load_save_done_and_login_done("", false)
			Signals.to_load_game_local_save.emit(player_data_.player_id)
			return
		Loggie.notice("载入了云存档数据: ", str(save_data_))
		# 比较保存游戏的时间戳，覆盖掉旧的那个
		if save_data_.saved_unix_ms > Global.saved_game_ms:
			Global.saved_game_ms = save_data_.saved_unix_ms
			Global.best_score = save_data_.best_score
			Loggie.notice("游戏云存档覆盖本地存档，因为时间戳较新")
	
	# 登陆已认证
	Global.is_authenticated = true
	#_wait_load_save_done_and_login_done(player_data_.player_id, true)
	Signals.to_load_game_local_save.emit(player_data_.player_id)

func _on_load_game_local_save_done():
	Signals.login_done.emit(Global.is_authenticated)

func _on_game_save_to_remote(bytes: PackedByteArray, origin_data: Structure.UserSaveData):
	if play_services != null:
		# 保存游戏数据
		play_services.call("saveGame", SAVED_GAME_NAME, "", bytes, 0, 0)
		# 提交排行榜数据
		if origin_data.best_score >= Constants.COMMIT_LEADERBOARD_MIN_SCORE:
			play_services.call("submitScore", SCORE_LEADERBOARD_ID, origin_data.best_score)

func _on_game_saved_to_remote(is_saved: bool, save_data_name: String, save_data_description: String):
	if not is_saved:
		Loggie.warn("游戏数据", save_data_name, "保存失败")
		return
	Loggie.notice("游戏数据", save_data_name, "保存到云端成功", save_data_description)

func _on_conflict_emitted(json_data: String):
	var json := JSON.new()
	var err := json.parse(json_data)

	if err != OK:
		Loggie.warn("JSON 解析失败: %s (line %d)" % [
			json.get_error_message(),
			json.get_error_line()
			])
		return
	
	var data = json.data
	if data.origin == "SAVE":
		pass
	elif data.origin == "LOAD":
		pass
	else:
		return

func _on_score_submitted(is_success: bool, leaderboard_id: String):
	if is_success:
		Loggie.notice("排行榜 %s 提交 %s" % [leaderboard_id, "成功"])
	else:
		Loggie.warn("排行榜 %s 提交 %s" % [leaderboard_id, "失败"])

func _on_score_loaded(leaderboard_id: String, json_data: String):
	Loggie.notice("排行榜 %s 载入数据: %s" % [leaderboard_id, json_data])

# 按钮点击示例：手动登录
func _on_login_button_pressed():
	login()

# 按钮点击示例：显示排行榜
func _on_show_leaderboard():
	if play_services != null:
		play_services.call("showLeaderboard", SCORE_LEADERBOARD_ID)

# 按钮点击示例：显示成就
func _on_show_achievements():
	if play_services != null:
		play_services.show_achievements()
