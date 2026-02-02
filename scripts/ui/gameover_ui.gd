extends Control

@onready var medal_tex: TextureRect = $"ScoreTextureRect/MedalTexture"
@onready var best_score_tex: ScoreUI = $"ScoreTextureRect/BestScore"
@onready var current_score_tex: ScoreUI = $"ScoreTextureRect/CurrentScore"

func _on_play_button_pressed() -> void:
	SceneChanger.play_fade(func():
		await SceneChanger.sleep(0.2)
		Signals.re_enter_game.emit()
	)

func _on_leaderboard_button_pressed() -> void:
	Signals.show_leaderboard.emit()

func _set_medal(score: int) -> void:
	if score >= 100:
		medal_tex.texture = preload("res://resources/pic/medals_3.png")
	elif score >= 50:
		medal_tex.texture = preload("res://resources/pic/medals_2.png")
	elif score >= 20:
		medal_tex.texture = preload("res://resources/pic/medals_1.png")
	else:
		medal_tex.texture = preload("res://resources/pic/medals_0.png")