extends CanvasLayer

@onready var pause_screen = $PauseScreen
@onready var shortcuts_label = $ShortcutsLabel

var main_menu = preload ("res://scenes/ui/main_menu.tscn")

func _ready() -> void:
	Global.show_shortcuts.connect(_on_show_shortcuts)
	Global.hide_shortcuts.connect(_on_hide_shortcuts)
	shortcuts_label.text = "   "

func _on_show_shortcuts(shortcuts: PackedStringArray) -> void:
	for shortcut in shortcuts:
		shortcuts_label.text += shortcut 
	shortcuts_label.text.rstrip(',')

func _on_hide_shortcuts() -> void:
	shortcuts_label.text = "   "

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
