extends Node

var login_template := preload("res://scenes/ui/login.tscn")
var loading_screen_template := preload("res://scenes/ui/loading_screen.tscn")
@export var music_file: AudioStream


func start_game() -> void:
	get_node("GameUpdater").queue_free()
	add_child(login_template.instantiate())


func _ready() -> void:
	get_node("GameUpdater").update_done.connect(start_game)
	AudioSystem.play_music(music_file)


func _process(_delta: float) -> void:
	pass
