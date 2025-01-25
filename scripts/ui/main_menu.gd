extends Control

var settings := load("res://scenes/ui/settings.tscn")
var loading_screen := load("res://scenes/ui/loading_screen.tscn")
var login_screen := load("res://scenes/ui/login.tscn")


func _on_play_button_pressed() -> void:
	print("Starting game")
	get_parent().add_child(loading_screen.instantiate())
	queue_free()


func _on_settings_button_pressed() -> void:
	print("Entering settings")
	get_parent().add_child(settings.instantiate())
	queue_free()


func _on_quit_button_pressed() -> void:
	print("Quitting game")
	get_tree().quit()


func _on_profile_button_pressed() -> void:
	print("Viewing profile is not implemented")


func _on_logout_button_pressed() -> void:
	Auth.delete_user_info()
	get_parent().add_child(login_screen.instantiate())
	queue_free()
