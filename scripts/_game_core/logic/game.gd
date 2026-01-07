class_name Game

enum GameState {
	NotStart = 0,
	Running = 1,
	Pause = 2,
	Finished = 3,
}

class EnterGameInfo:
	var player_id: int # 玩家id
	var number: int # 編號

var state_: GameState # 遊戲狀態
var max_frame_: int # 最大幀序號

