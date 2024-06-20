extends CanvasLayer

var main_menu = preload ("res://scenes/ui/main_menu.tscn")


func _on_return_button_pressed():
	get_parent().add_child(main_menu.instantiate())
	queue_free()
	
