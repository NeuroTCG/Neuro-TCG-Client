extends Button

@export var button_action: MatchManager.Actions
@export var shortcut_key: String

@onready var buttons := get_parent()

var mouse_over := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


func _process(_delta) -> void:
	if buttons.visible and visible and Input.is_action_just_pressed(shortcut_key):
		print(visible, buttons.visible)
		_on_pressed()


func _on_pressed() -> void:
	release_focus()

	if button_action == MatchManager.Actions.VIEW:
		MatchManager.action_view.emit(get_parent().get_parent())
		return

	if MatchManager.input_paused or MatchManager._opponent_turn:
		if MatchManager._opponent_turn:
			Global.notice.emit("It is not your turn!")
		if MatchManager.input_paused:
			Global.notice.emit("Wait until cards have finished moving!")
		return

	if button_action == MatchManager.Actions.SUMMON:
		var player_ram = Global.ram_manager.player_ram
		if player_ram < (buttons.get_parent() as Card).info.cost:
			Global.notice.emit("Insufficent Ram to summon this card!")
			Global.hide_player_slots.emit()
			return

	MatchManager.current_action = button_action
	Global.close_view.emit()
	buttons.hide()


func _on_mouse_entered() -> void:
	mouse_over = true


func _on_mouse_exited() -> void:
	mouse_over = false
