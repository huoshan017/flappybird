class_name Instance

enum InstanceMode {
	Play = 0,
	Replay = 1,
}

class playerData:
	var player_id: int
	var cmd_list: Array[CmdData]

	func is_empty() -> bool:
		if cmd_list == null:
			return 0
		return cmd_list.size() == 0

	func clear() -> void:
		cmd_list.clear()
		player_id = 0

	func add(cmd_data: CmdData) -> void:
		if cmd_list == null:
			cmd_list = []
		cmd_list.append(cmd_data)

class frameData:
	var frame_num: int
	var player_data_list: Array[playerData]

	func clear() -> void:
		frame_num = 0
		if player_data_list != null:
			player_data_list.clear()


var player_num_: int # 玩家人數
var frame_ms_: int # 幀毫秒數
var instannceMode_: InstanceMode = InstanceMode.Play # 實例播放模式
var record_: Record = null # 錄像數據，只有在重播模式下才有用
var frame_list_: Array[frameData] = [] # 游戲幀數據列表
var player_list_: Array[int] = [] # 玩家id列表