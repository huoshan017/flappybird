extends Control

func _on_tap_button_pressed() -> void:
	Signals.tap_play.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_on_tap_button_pressed()
