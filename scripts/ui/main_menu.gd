extends Control

var game = load("res://scenes/game/game.tscn")
var settings = load("res://scenes/ui/settings.tscn")

func _on_play_button_pressed():
	print("Starting game")
	get_parent().add_child(game.instantiate())
	queue_free()

func _on_settings_button_pressed():
	print("Entering settings")
	get_parent().add_child(settings.instantiate())
	queue_free()

func _on_quit_button_pressed():
	print("Quitting game")
	get_tree().quit()

func _on_profile_button_pressed():
	print("Viewing profile is not implemented")
