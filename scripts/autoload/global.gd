extends Node

var game_state: Enums.GameState = Enums.GameState.STATE_NONE
var player: TEntity = null

func is_player_entity(entity: TEntity) -> bool:
	return player.id == entity.id

func is_floor_entity(entity: TEntity) -> bool:
	return entity.type_id == Enums.EntityType.Floor