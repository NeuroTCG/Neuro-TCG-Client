extends Control

var main_menu = preload ("res://scenes/ui/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_return_button_pressed():
	get_parent().add_child(main_menu.instantiate())
	queue_free()
