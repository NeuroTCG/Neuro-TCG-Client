extends Node

var version = "early development build"

var main_menu_template = preload("res://scenes/ui/main_menu.tscn")
var loading_screen_template = preload("res://scenes/ui/loading_screen.tscn")
@export var music_file : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_menu_template.instantiate())
	AudioSystem.play_music(music_file)
	
	User.client = Client.new()
	add_child(User.client)
	await User.client.wait_until_connection_opened()
	User.send_command("version", [version])
