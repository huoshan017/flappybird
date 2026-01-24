extends Parallax2D

var camera: Camera2D

func _ready():
	# 确保初始状态完全归零
	screen_offset = Vector2.ZERO
	scroll_offset = Vector2.ZERO
	
	# 获取当前场景中的摄像机
	camera = get_viewport().get_camera_2d()
	
	# 监听窗口变化信号
	get_tree().get_root().size_changed.connect(align_now)
	
	# 等待一帧确保所有节点就绪
	await get_tree().process_frame
	align_now()

func _process(_delta):
	# 每帧将背景位置强行对齐到摄像机中心
	if camera:
		global_position = camera.get_screen_center_position()

func align_now():
	var screen_size = get_viewport_rect().size
	var sprite = $Sprite2D
	
	if sprite and sprite.texture:
		var tex_size = sprite.texture.get_size()
		
		# 1. 缩放适配高度
		var s = screen_size.y / tex_size.y
		sprite.scale = Vector2(s, s)
		
		# 2. 子节点在原点居中
		sprite.centered = true
		sprite.position = Vector2.ZERO
		sprite.offset = Vector2.ZERO
		
		# 3. 开启横向循环平铺（防止飞出图片范围）
		repeat_size.x = tex_size.x * s
		repeat_times = 3