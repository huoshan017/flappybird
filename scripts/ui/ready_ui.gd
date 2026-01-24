extends Control

func _ready() -> void:
	set_process_input(is_visible_in_tree())
	visibility_changed.connect(_on_visibility_changed)

func _input(event: InputEvent) -> void:
	# 防止隐藏时还会接收到用户输入
	if not is_visible_in_tree(): return
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_on_tap_button_pressed()

func _on_tap_button_pressed() -> void:
	Signals.tap_play.emit()

func _on_visibility_changed():
	set_process_input(is_visible_in_tree())