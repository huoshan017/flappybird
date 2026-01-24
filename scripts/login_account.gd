extends Node

const SAVED_GAME_NAME = "saved_game"

# 定义插件单例名称，方便后续调用
var play_services = null

# 玩家数据
var player_data: PlayGamesPlayer

func _ready():
	# 1. 检查插件是否在 Android 环境下可用
	var os_name = OS.get_name()
	if os_name == "Android":
		if Engine.has_singleton("GodotPlayGameServices"):
			play_services = Engine.get_singleton("GodotPlayGameServices") 
			if play_services == null:
				Loggie.error("错误：无法获取 GodotPlayGameServices 单例")
				return

			# 打印出这个插件在 Android 端真正注册的所有函数名
			Loggie.notice("--- 插件函数列表 ---")
			for method in play_services.get_method_list():
				Loggie.notice(method.name)
		
			# 打印出这个插件真正注册的所有信号名
			Loggie.notice("--- 插件信号列表 ---")
			for sig in play_services.get_signal_list():
				Loggie.notice(sig.name)

			_connect_signals()
			Loggie.notice("Google Play Services 插件已加载")
		
			# 2. 自动尝试静默登录
			# 用户如果之前登录过，这次不会弹出任何窗口
			login()
		else:
			Loggie.error("错误：已在 Android 运行但未发现插件，请检查导出设置中的 Plugins 勾选状态")
	else:
		Loggie.notice("当前平台%s没有登陆功能" % os_name)

# 连接插件返回的信号
func _connect_signals():
	# 保存本地文件功能发送过来的信号，用于请求保存游戏数据到云端
	Signals.save_game_remote.connect(_on_game_save_to_remote)
	# 登录成功与否的信号
	play_services.userAuthenticated.connect(_on_user_authenticated)
	# 获取玩家信息的信号
	play_services.currentPlayerLoaded.connect(_on_player_info_loaded)
	# 载入游戏云存档完成的信号
	play_services.gameLoaded.connect(_on_game_loaded_from_remote)
	# 保存游戏云存档完成的信号
	play_services.gameSaved.connect(_on_game_saved_to_remote)

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
		Loggie.notice("登录失败：用户未授权或已登出。")
		Loggie.notice("使用本地存储的数据")

func _on_sign_in_error(error_code: int):
	# 常见的错误码对照：
	# 4: 签名校验失败 (SHA-1 不匹配)
	# 17: 登录取消或网络问题
	Loggie.error("Google Play 登录出错。代码: %d" % error_code)

func _on_player_info_loaded(player_info: String):
	# player_info 包含: display_name, player_id, icon_image_uri 等
	var data = JSON.parse_string(player_info)
	player_data = PlayGamesPlayer.new(data)
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
		if Global.player_id != player_data.player_id:
			Global.player_id = player_data.player_id
		var os_name = OS.get_name()
		if os_name == "Android":
			Global.player_platform = Enums.PlayerPlatform.GOOGLE
		Signals.save_game_local.emit(true, false)
		Loggie.notice("没有游戏云存档, 把player_id ", player_data.player_id, " 保存到了本地存档里")
	else:
		var dic = bytes_to_var(snapshot.content) as Dictionary
		# 比较保存游戏的时间戳，覆盖掉旧的那个
		if dic.saved_unix_ms > Global.saved_game_ms:
			Global.saved_game_ms = dic.saved_unix_ms
			Global.best_score = dic.best_score
			Loggie.notice("游戏云存档覆盖本地存档，因为时间戳较新")

func _on_game_save_to_remote(save_data: PackedByteArray):
	play_services.call("saveGame", SAVED_GAME_NAME, "", save_data, 0, 0)
	#play_services.saveGame(SAVED_GAME_NAME, "", save_data)

func _on_game_saved_to_remote(is_saved: bool, save_data_name: String, save_data_description: String):
	if not is_saved:
		Loggie.warn("游戏数据", save_data_name, "保存失败")
		return
	Loggie.notice("游戏数据", save_data_name, "保存到云端成功", save_data_description)

# 按钮点击示例：手动登录
func _on_login_button_pressed():
	login()

# 按钮点击示例：显示排行榜
func _on_show_leaderboard():
	play_services.show_leaderboard("YOUR_LEADERBOARD_ID_HERE")

# 按钮点击示例：显示成就
func _on_show_achievements():
	play_services.show_achievements()
