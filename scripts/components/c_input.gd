class_name CInput
extends Component

var _is_jumping: bool = false

func _init() -> void:
	pass

func is_jumping() -> bool:
	if _is_jumping or Input.is_action_just_pressed("jump"):
		_is_jumping = false
		return true
	return false
	
func handle_input_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_is_jumping = true
			print("手指按下：", event.index, " 位置：", event.position)
		else:
			print("手指抬起：", event.index, " 位置：", event.position)