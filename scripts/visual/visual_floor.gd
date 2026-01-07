class_name VisualFloor
extends TNode2D

@onready var sprite1: Sprite2D = $Sprite2D
@onready var sprite2: Sprite2D = $Sprite2D2

var floor_tile_width: float
var counter: int = 0
var distance_moved: float = 0.0

func _ready() -> void:
    floor_tile_width = get_viewport().get_visible_rect().size.x
    Loggie.notice("Floor tile width: %f" % floor_tile_width)

func _process(delta: float) -> void:
    if Global.game_state == Enums.GameState.STATE_GAMEOVER or Global.game_state == Enums.GameState.STATE_BEFORE_GAMEOVER or Global.game_state == Enums.GameState.STATE_PAUSED:
        return

    distance_moved += Constants.CHARACTER_HORIZENTAL_SPEED * delta
    if distance_moved >= floor_tile_width:
        if counter % 2 == 0:
            sprite1.global_position.x = sprite2.global_position.x + floor_tile_width
        else:
            sprite2.global_position.x = sprite1.global_position.x + floor_tile_width
        counter += 1
        distance_moved -= floor_tile_width