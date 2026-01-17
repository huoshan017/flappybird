# SoundManager
extends Node

var flap_sound: AudioStream = preload("res://resources/audio/flap.wav")
var hit_sound: AudioStream = preload("res://resources/audio/hit.wav")
var die_sound: AudioStream = preload("res://resources/audio/die.wav")
var point_sound: AudioStream = preload("res://resources/audio/point.wav")

@export var sfx_players: Array[AudioStreamPlayer] = []

var _next_player_index: int = 0

func _ready() -> void:
    if sfx_players.size() == 0:
        for i in range(20):
            var sfx_player = AudioStreamPlayer.new()
            add_child(sfx_player)
            sfx_players.append(sfx_player)
    Loggie.notice("SoundManager ready")

func play_sfx(stream: AudioStream) -> void:
    if _next_player_index >= sfx_players.size():
        _next_player_index = 0
    var sfx_player = sfx_players[_next_player_index]
    sfx_player.stream = stream
    sfx_player.play()
    _next_player_index += 1