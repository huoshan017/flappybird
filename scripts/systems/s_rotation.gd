class_name RotationSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([CRotation]).iterate([CRotation])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	if Global.game_state == Enums.GameState.STATE_GAMEOVER or Global.game_state == Enums.GameState.STATE_PAUSED:
		return

	var s = entities.size()
	var c_rotations = components[0]
	for i in s:
		var entity = entities[i]
		var c_rotation = c_rotations[i] as CRotation
		var node = entity as Node2D

		var delta_rotation = c_rotation.rotation_speed * delta
		node.rotation_degrees += delta_rotation
		Signals.entity_update.emit(entity)