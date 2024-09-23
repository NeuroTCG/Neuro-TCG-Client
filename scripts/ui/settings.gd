extends Control

var main_menu = preload("res://scenes/ui/main_menu.tscn")


func _on_return_button_pressed():
	SavedSettings.save_settings.emit()

	get_parent().add_child(main_menu.instantiate())
	queue_free()
