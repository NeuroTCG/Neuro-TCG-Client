extends Node

var version := "early development build"

var login_template := preload("res://scenes/ui/login.tscn")
var loading_screen_template := preload("res://scenes/ui/loading_screen.tscn")
@export var music_file: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(login_template.instantiate())
	AudioSystem.play_music(music_file)
