# SoundManager
extends Node

var flap_sound: AudioStream = preload("res://resources/audio/flap.mp3")
var hit_sound: AudioStream = preload("res://resources/audio/hit.mp3")
var die_sound: AudioStream = preload("res://resources/audio/die.mp3")
var point_sound: AudioStream = preload("res://resources/audio/point.mp3")

func play_sfx(stream: AudioStream) -> void:
    var sfx_player = AudioStreamPlayer.new()
    sfx_player.stream = stream
    add_child(sfx_player)
    #sfx_player.bus = "SFX"
    sfx_player.play()
    sfx_player.finished.connect(sfx_player.queue_free)