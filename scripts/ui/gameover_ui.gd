extends Control

@onready var medal_tex: TextureRect = $"ScoreTextureRect/MedalTexture"
@onready var best_score_tex: ScoreUI = $"ScoreTextureRect/BestScore"
@onready var current_score_tex: ScoreUI = $"ScoreTextureRect/CurrentScore"

func _on_play_button_pressed() -> void:
	SceneChanger.play_fade(func():
		await SceneChanger.sleep(0.2)
	)
	Signals.re_enter_game.emit()
	Loggie.notice("Play button pressed, re-entering game signal emitted")
