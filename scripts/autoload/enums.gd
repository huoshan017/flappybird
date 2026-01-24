extends Node

enum PlayerPlatform {
	NONE,
	GOOGLE,
	APPLE,
}

enum GameState {
	STATE_NONE,
	STATE_MENU,
	STATE_READY,
	STATE_GAMEPLAY,
	STATE_PAUSED,
	STATE_BEFORE_GAMEOVER, # 这个状态用来处理在结束前坠落到地面的过程
	STATE_GAMEOVER
}

enum CollisionObjectType {
	AREA,
	RIGID,
	STATIC,
	CHARACTER,
}

enum ShapeType {
	SHAPE_CIRCLE,
	SHAPE_RECTANGLE,
	SHAPE_POLYGON,
	SHAPE_CAPSULE,
	SHAPE_SEGMENT,
	SHAPE_WORLD_BOUNDARY,
}

# scripts/entity/entity.gd
enum EntityType {
	None,
	Bird = 1,
	Floor = 100,
	PipeUp = 101,
	PipeDown = 102,
}