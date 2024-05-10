extends Control

var main_menu = preload("res://scenes/ui/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	User.do_something.connect(_on_do_something)
	
func _on_do_something() -> void:
	print("Doing something")

func _on_return_button_pressed():
	get_parent().add_child(main_menu.instantiate())
	queue_free()
