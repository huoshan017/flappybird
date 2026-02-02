extends Node

var game_state: Enums.GameState = Enums.GameState.STATE_NONE
var player: TEntity = null
var is_authenticated: bool
var player_id: String = Constants.DEFAULT_PLAYER_ID
var player_platform: = Enums.PlayerPlatform.NONE
var saved_game_ms: int
var current_score: int = 0
var best_score: int = 0

func is_player_entity(entity: TEntity) -> bool:
	return player.id == entity.id

func is_floor_entity(entity: TEntity) -> bool:
	return entity.type_id == Enums.EntityType.Floor

func get_unix_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000)