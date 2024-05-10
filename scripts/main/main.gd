extends Node2D

var version = "early development build"

var main_menu = preload("res://scenes/ui/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_menu.instantiate())
	
	User.client = Client.new()
	add_child(User.client)
	await User.client.wait_until_connection_opened()
	User.send_command("version", [version])
	
	
