class_name ActionChoiceButton
extends Button

@export var button_action: MatchManager.Actions
@export var shortcut_key: String

@onready var buttons := get_parent()

var mouse_over := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	RenderOpponentAction.opponent_finished.connect(update_conditions)
	VerifyClientAction.player_finished.connect(update_conditions)


func _process(_delta) -> void:
	if buttons.visible and visible and Input.is_action_just_pressed(shortcut_key):
		print(visible, buttons.visible)
		_on_pressed()


func update_conditions() -> bool:
	self.disabled = false
	match button_action:
		MatchManager.Actions.SUMMON:
			self.tooltip_text = "Summon this card on the board"
		MatchManager.Actions.MAGIC:
			self.tooltip_text = "Use this magic card"
		MatchManager.Actions.ABILITY:
			self.tooltip_text = "Activate this cards ability"
		MatchManager.Actions.ATTACK:
			self.tooltip_text = "Attack using this card"
		MatchManager.Actions.SWITCH:
			self.tooltip_text = "Switch place with another card"
		MatchManager.Actions.VIEW:
			self.tooltip_text = "View details about this card"
			return true  # view is always possible
		MatchManager.Actions.IDLE:
			assert(false, "no button should have the IDLE action")
		_:
			assert(false, "button action not handled")

	if MatchManager._opponent_turn:
		self.disabled = true
		self.tooltip_text += "\nIt's not your turn"
		return false

	var card = buttons.get_parent() as Card
	var player_ram = Global.ram_manager.player_ram

	if button_action == MatchManager.Actions.SUMMON || button_action == MatchManager.Actions.MAGIC:
		var cost = card.info.cost
		if player_ram < cost:
			self.disabled = true
			self.tooltip_text += "\nYou need at least %d RAM to use this card." % cost
			return false

	if button_action == MatchManager.Actions.ABILITY:
		var cost = card.current_ability_cost
		if player_ram < cost:
			self.disabled = true
			self.tooltip_text += "\nYou need at least %d RAM to use this ability." % cost
			return false

	return true


func _on_pressed() -> void:
	release_focus()

	if self.disabled:
		return

	if button_action == MatchManager.Actions.VIEW:
		MatchManager.action_view.emit(get_parent().get_parent())
		return

	if MatchManager.input_paused:
		Global.notice.emit("Wait until cards have finished moving!")
		return

	if button_action == MatchManager.Actions.SUMMON:
		var player_ram = Global.ram_manager.player_ram
		if player_ram < (buttons.get_parent() as Card).info.cost:
			Global.notice.emit("Insufficent Ram to summon this card!")
			Global.hide_player_slots.emit()
			return
	if button_action == MatchManager.Actions.MAGIC:
		var player_ram = Global.ram_manager.player_ram
		if player_ram < (buttons.get_parent() as Card).current_ability_cost:
			Global.notice.emit("Insufficent Ram to use this card!")
			Global.hide_player_slots.emit()
			return


	MatchManager.current_action = button_action
	Global.close_view.emit()
	buttons.hide()


func _on_mouse_entered() -> void:
	mouse_over = true


func _on_mouse_exited() -> void:
	mouse_over = false
