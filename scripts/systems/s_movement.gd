class_name MovementSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([CVelocity, CTransform]).iterate([CVelocity, CTransform])

# 物理更新，不用delta，使用固定的时间步长
func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	if Global.game_state == Enums.GameState.STATE_GAMEOVER or Global.game_state == Enums.GameState.STATE_PAUSED:
		return

	if entities.size() == 0:
		return
	
	for e in entities:
		var velocity = e.get_component(CVelocity)
		if velocity.velocity == Vector2.ZERO:
			continue

		if Global.is_player_entity(e):
			continue
			
		var transform = e.get_component(CTransform)
		var motion = velocity.velocity * delta
		transform.position += motion

		Signals.entity_update.emit(e)