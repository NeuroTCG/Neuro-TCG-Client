extends CanvasLayer

@onready var pause_screen = $PauseScreen

var main_menu = preload ("res://scenes/ui/main_menu.tscn")

func _process(delta) -> void:
	if Input.is_action_just_pressed("pause"):
		if pause_screen.visible: 
			pause_screen.visible = false
		else:
			pause_screen.visible = true 
		
func return_to_menu() -> void:
	get_parent().get_parent().add_child(main_menu.instantiate())
	get_parent().queue_free()
	
func _on_quit_button_pressed():
	return_to_menu()
