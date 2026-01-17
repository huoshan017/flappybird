class_name ScoreUI
extends Control

@export var digit_textures: Array[Texture2D]
@export var max_digits := 8

@onready var box := $CenterBox

func _ready() -> void:
	while box.get_child_count() < max_digits:
		var t := TextureRect.new()
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.set_process(false)
		box.add_child(t)
	Signals.start_game.connect(_on_start_game)
	Signals.score_update.connect(_on_set_score)

func _on_start_game() -> void:
	_on_set_score(0)
 
func _on_set_score(value: int):
	var s := str(value)

	if s.length() > max_digits:
		s = s.substr(s.length() - max_digits)

	for i in range(max_digits):
		var rect := box.get_child(i)
		if i < s.length():
			rect.texture = digit_textures[int(s[i])]
			rect.visible = true
		else:
			rect.visible = false
