class_name VisualBird
extends TNode2D

func _ready() -> void:
	Signals.entity_flapped.connect(_on_flapped)
	Signals.entity_collide.connect(_on_collide)
	Signals.entity_dead.connect(_on_dead)

func play():
	$AnimatedSprite2D.play("bird_flying")

func stop():
	$AnimatedSprite2D.stop()

func _on_flapped(_entity: Entity) -> void:
	SoundManager.play_sfx(SoundManager.flap_sound)

func _on_collide(_entity: Entity, _collider: Entity) -> void:
	SoundManager.play_sfx(SoundManager.hit_sound)

func _on_dead(_entity: Entity) -> void:
	SoundManager.play_sfx(SoundManager.die_sound)