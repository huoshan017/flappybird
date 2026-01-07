class_name Core

enum State {
	Idle = 0,
	Prepare = 1,
	Running = 2,
}

class GameArgs:
	var player_num: int
	var frame_ms: int
