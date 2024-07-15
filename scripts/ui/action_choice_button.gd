extends Button

@export var button_action: MatchManager.Actions 

var mouse_over := false 

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_pressed)
		
func _on_pressed() -> void:
	release_focus()
	if MatchManager.input_paused:
		return 
	
	MatchManager.current_action = button_action 

func _on_mouse_entered():
	mouse_over = true 

func _on_mouse_exited():
	mouse_over = false 
