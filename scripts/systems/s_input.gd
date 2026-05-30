class_name InputSystem
extends System

var _input_comp: CInput

func query() -> QueryBuilder:
	return q.with_all([CInput]).iterate([CInput])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		return

	var s = entities.size()
	if s != 1:
		return

	var input_comps = components[0] as Array
	if _input_comp == null:
		_input_comp = input_comps[0]	

	_input_comp.handle_process(delta)

func _input(event: InputEvent) -> void:
	if Global.game_state != Enums.GameState.STATE_GAMEPLAY:
		return

	if _input_comp == null:
		return

	_input_comp.handle_input_event(event)
