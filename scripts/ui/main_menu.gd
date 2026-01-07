extends Control

func _on_play_button_pressed() -> void:
	Signals.enter_game.emit()

func _on_rate_button_pressed() -> void:
	pass

func _on_score_button_pressed() -> void:
	pass
