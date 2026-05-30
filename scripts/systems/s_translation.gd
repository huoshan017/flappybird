class_name TranslationSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([CSize, CTranslation]).iterate([CTranslation])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	if Global.game_state == Enums.GameState.STATE_GAMEOVER or Global.game_state == Enums.GameState.STATE_PAUSED:
		return

	var s = entities.size()
	var c_translations = components[0]
	for i in s:
		var entity = entities[i]
		if EntityHelper._check_delay(entity, delta):
			continue

		var c_translation = c_translations[i] as CTranslation
		if c_translation.s_speed == 0 or c_translation.s_movement_distance == 0	:
			continue

		var node = entity as Node2D
		var delta_movement = c_translation.s_speed * c_translation.s_direction * delta
		var delta_movement_length = delta_movement.length()
		
		#Loggie.notice("delta_movement: " + str(delta_movement) + ", delta_movement_length: " + str(delta_movement_length))
		if not c_translation.s_is_cycle:
			if c_translation.moved_distance + delta_movement_length > c_translation.s_movement_distance:
				c_translation.moved_distance = c_translation.s_movement_distance
				var last_delta = c_translation.s_direction * (c_translation.s_movement_distance - c_translation.moved_distance)
				node.position += last_delta
			else:
				c_translation.moved_distance += delta_movement_length
				node.position += delta_movement
		else:
			if c_translation.moved_distance + delta_movement_length > c_translation.s_movement_distance:
				var last_delta = c_translation.s_direction * (c_translation.s_movement_distance - c_translation.moved_distance)
				if not c_translation.is_reversed:
					node.position += last_delta
				else:
					node.position -= last_delta
				c_translation.moved_distance = 0
				c_translation.is_reversed = not c_translation.is_reversed
				#Loggie.notice("last_delta: " + str(last_delta) + ", is_reversed: " + str(c_translation.is_reversed))
			else:
				if c_translation.is_reversed:
					node.position -= delta_movement
				else:
					node.position += delta_movement	
				c_translation.moved_distance += delta_movement_length

		Signals.entity_update.emit(entity)
