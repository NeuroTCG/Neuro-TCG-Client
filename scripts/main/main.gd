extends Node

var main_menu_template := preload("res://scenes/ui/main_menu.tscn")
var loading_screen_template := preload("res://scenes/ui/loading_screen.tscn")
@export var music_file: AudioStream


func start_game() -> void:
	get_node("GameUpdater").queue_free()
	add_child(main_menu_template.instantiate())
	AudioSystem.play_music(music_file)


func _ready() -> void:
	get_node("GameUpdater").update_done.connect(start_game)


func _process(_delta: float) -> void:
	pass
