extends Control

func _on_play_button_pressed() -> void:
	SceneChanger.play_fade(func():
		await SceneChanger.sleep(0.2)
	)
	Signals.re_enter_game.emit()
	Loggie.notice("Play button pressed, re-entering game signal emitted")
