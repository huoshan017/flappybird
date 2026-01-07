class_name CCharacterBody
extends Component

var character_body_: CharacterBody2D

func _init(character_body: CharacterBody2D = CharacterBody2D.new()) -> void:
	character_body_ = character_body