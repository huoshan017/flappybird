class_name VisualBird
extends TNode2D

const FLAP_ANIMATION_DURATION: float = 0.8

@onready var animation_: AnimatedSprite2D = $AnimatedSprite2D

var is_flapping: bool = false
var flap_timer: float = 0.0
var origin_speed_scale : float

func _ready() -> void:
	origin_speed_scale = animation_.speed_scale
	Signals.entity_flapped.connect(_on_flapped)
	Signals.entity_collide.connect(_on_collide)
	Signals.entity_dead.connect(_on_dead)
	Signals.entity_pass_through.connect(_on_pass_through)

func play():
	animation_.play("bird_flying")

func stop():
	animation_.stop()

func _process(delta: float) -> void:
	if is_flapping:
		flap_timer += delta
		if flap_timer >= FLAP_ANIMATION_DURATION:
			animation_.speed_scale = origin_speed_scale
			is_flapping = false
			flap_timer = 0.0

func _on_flapped(_entity: Entity) -> void:
	SoundManager.play_sfx(SoundManager.flap_sound)
	if is_flapping:
		return
	animation_.speed_scale = origin_speed_scale * 4.5
	is_flapping = true

func _on_collide(_entity: Entity, _collider: Entity) -> void:
	SoundManager.play_sfx(SoundManager.hit_sound)

func _on_dead(_entity: Entity) -> void:
	SoundManager.play_sfx(SoundManager.die_sound)

func _on_pass_through(_entity: Entity) -> void:
	SoundManager.play_sfx(SoundManager.point_sound)
