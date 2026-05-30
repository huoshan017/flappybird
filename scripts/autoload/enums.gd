extends Node

enum PlayerPlatform {
	NONE,
	IOS,
	IPADOS,
	STOCK_ANDROID = 10,
}

enum GameState {
	STATE_NONE,
	STATE_LOGO,
	STATE_LOGIN,
	STATE_MENU,
	STATE_READY,
	STATE_GAMEPLAY,
	STATE_PAUSED,
	STATE_BEFORE_GAMEOVER, # 这个状态用来处理在结束前坠落到地面的过程
	STATE_GAMEOVER
}

enum GamePlaySubState {
	SUBSTATE_NONE,
	SUBSTATE_PLAYING,
	SUBSTATE_PAUSED,
	SUBSTATE_BEFORE_GAMEOVER,
	SUBSTATE_GAMEOVER,
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
	Pipe = 200,
}

enum ActionType {
	None,
	UpFlying = 1, # 往上飞
	DownFlying = 2, # 往下飞
	Forward = 3, # 冲刺
}