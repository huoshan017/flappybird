# 输入组件

class_name CInput
extends Component

enum InputStateType {
	None, Pressing, Released,
}

const UP_STATE_SECS = 0.2

# 按下计时
var pressing_timer: float = 0.0

var _state: InputStateType
var _action: Enums.ActionType
var _is_continuous: bool = false # 是否持续

func get_action() -> Enums.ActionType:
	#if _state != InputStateType.None:
	#	var state = _state
	#	_state = InputStateType.None
	#	return INPUT_2_ACTIONS[state]
	#return Enums.ActionType.None
	# 非持续状态下，获取一次性动作后重置
	if _action != Enums.ActionType.None and not _is_continuous:
		var action = _action
		_action = Enums.ActionType.None
		return action
	return _action

func handle_process(delta: float) -> void:
	#if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
	#	return
	if _state == InputStateType.Pressing:
		Loggie.notice("!!!!! pressing timer: ", pressing_timer)
		pressing_timer += delta
		if pressing_timer >= UP_STATE_SECS:
			_action = Enums.ActionType.Forward
			_is_continuous = true
			Loggie.notice("!!!!! action forward")
	elif _state == InputStateType.Released:
		Loggie.notice("!!!!! released")
		if _action != Enums.ActionType.Forward:
			pressing_timer += delta
			if pressing_timer < UP_STATE_SECS:
				_action = Enums.ActionType.UpFlying
				Loggie.notice("!!!!! action up flying")
		_state = InputStateType.None
		pressing_timer = 0.0
	if _is_continuous: _is_continuous = false

func handle_input_event(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			_handle_key_event(event)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_mouse_button_event(event)
	elif event is InputEventScreenTouch:
		_handle_screen_touch_event(event)

func _handle_key_event(event: InputEventKey) -> void:
	if event.pressed:
		_state = CInput.InputStateType.Pressing
		Loggie.notice("按键", event.keycode, "按下")
	else:
		_state = CInput.InputStateType.Released
		Loggie.notice("按键", event.keycode, "抬起")

func _handle_mouse_button_event(event: InputEventMouseButton) -> void:
	var button_name: String
	if event.button_index == MOUSE_BUTTON_LEFT:
		button_name = "左键"
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		button_name = "右键"
	else:
		button_name = "中键"
	if event.pressed:
		_state = CInput.InputStateType.Pressing
		Loggie.notice("鼠标", button_name, "按下，位置：", event.position)	
	else:
		_state = CInput.InputStateType.Released
		Loggie.notice("鼠标", button_name, "抬起，位置：", event.position	)

func _handle_screen_touch_event(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_state = CInput.InputStateType.Pressing
		Loggie.notice("手指按下：", event.index, "位置：", event.position)
	else:
		_state = CInput.InputStateType.Released
		Loggie.notice("手指抬起：", event.index, "位置：", event.position)