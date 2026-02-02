extends Node

class UserSaveData extends Resource:
	var version: int = 0 # 版本号，每次保存时递增
	var best_score: int = 0 # 最佳分数
	var player_id: String = Constants.DEFAULT_PLAYER_ID # 玩家ID，跟使用的账号平台相关联
	var player_platform: int = Enums.PlayerPlatform.NONE # 游玩系统平台
	var saved_unix_ms: int = 0 # 保存的时间戳，Unix 毫秒时间戳

	func _reset_state() -> void:
		version = 0
		best_score = 0
		player_id = Constants.DEFAULT_PLAYER_ID
		player_platform = Enums.PlayerPlatform.NONE
		saved_unix_ms = 0

	func serialize(update_version: bool = false) -> PackedByteArray:
		saved_unix_ms = Global.get_unix_ms()
		if update_version:
			version += 1
		var data = {
			"version": version,
			"best_score": best_score,
			"player_id": player_id,
			"player_platform": player_platform,
			"saved_unix_ms": saved_unix_ms
		}
		return var_to_bytes(data)

	func deserialize(bytes: PackedByteArray) -> bool:
		var data = bytes_to_var(bytes)
		Loggie.notice("反序列化UserSaveData: ", str(data))
		if data is Dictionary:
			version = data.get("version", 0)
			best_score = data.get("best_score", 0)
			player_id = data.get("player_id", "")
			player_platform = data.get("player_platform", 0)
			saved_unix_ms = data.get("saved_unix_ms", 0)
			return true
		else:
			Loggie.warn("无法反序列化UserSaveData: 数据类型不匹配")
			return false