extends Node

# 定义插件单例名称，方便后续调用
var play_services = null

func _ready():
    # 1. 检查插件是否在 Android 环境下可用
    var os_name = OS.get_name()
    if os_name == "Android":
        if Engine.has_singleton("GodotPlayGameServices"):
            play_services = Engine.get_singleton("GodotPlayGameServices")
            if play_services == null:
                Loggie.error("错误：无法获取 GodotPlayGameServices 单例")
                return
            _connect_signals()
            print("Google Play Services 插件已加载")
        
            # 2. 自动尝试静默登录
            # 用户如果之前登录过，这次不会弹出任何窗口
            login()
        else:
            Loggie.error("错误：已在 Android 运行但未发现插件，请检查导出设置中的 Plugins 勾选状态")
    else:
        Loggie.notice("当前平台%s没有登陆功能" % os_name)

# 连接插件返回的信号
func _connect_signals():
    # 登录成功与否的信号
    play_services.android_is_user_authenticated_success.connect(_on_sign_in_success)
    play_services.android_is_user_authenticated_error.connect(_on_sign_in_error)
    
    # 获取玩家信息的信号
    play_services.android_player_info_loaded_success.connect(_on_player_info_loaded)

# 调用登录逻辑
func login():
    Loggie.notice("开始验证身份...")
    play_services.authenticate()

# --- 信号回调处理 ---

func _on_sign_in_success(is_authenticated: bool):
    if is_authenticated:
        Loggie.notice("登录成功！用户已授权。")
        # 登录成功后，通常接着获取玩家昵称或 ID
        play_services.load_player_info()
    else:
        Loggie.notice("登录失败：用户未授权或已登出。")

func _on_sign_in_error(error_code: int):
    # 常见的错误码对照：
    # 4: 签名校验失败 (SHA-1 不匹配)
    # 17: 登录取消或网络问题
    Loggie.error("Google Play 登录出错。代码: %d" % error_code)

func _on_player_info_loaded(player_info: Dictionary):
    # player_info 包含: display_name, player_id, icon_image_uri 等
    Loggie.notice("欢迎回来: " + player_info.display_name)
    Loggie.notice("玩家 ID: " + player_info.player_id)

# 按钮点击示例：手动登录
func _on_login_button_pressed():
    login()

# 按钮点击示例：显示排行榜
func _on_show_leaderboard():
    play_services.show_leaderboard("YOUR_LEADERBOARD_ID_HERE")

# 按钮点击示例：显示成就
func _on_show_achievements():
    play_services.show_achievements()