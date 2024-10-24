extends Control

var menu := load("res://scenes/ui/main_menu.tscn")

func _on_menu_button_pressed() -> void:
	get_parent().add_child(menu.instantiate())
	queue_free()
