extends Node2D
class_name Card

@onready var animation_player := $AnimationPlayer
@onready var card_hover_sprite = $CardBack/CardHover
@onready var card_unhover_sprite = $CardBack/CardUnhover
@onready var collision = $Area2D/CollisionShape2D
@onready var card_sprite = $CardBack/CardFront
@onready var attack_sprite = $AttackSprite
@onready var buttons = %Buttons
@onready var atk_label = %AtkLabel
@onready var hp_label = %HpLabel
@onready var seal_sprite = $SealSprite
@onready var shield_sprite = $ShieldSprite

enum Placement {
	DECK,
	HAND,
	PLAYMAT,
	DESTROYED,
}

enum TurnPhase {
	Done = 0,
	Action = 1,
	MoveOrAction = 2,
}

# TODO: remove
var owned_by_player := true

## no touchy
var state: CardState
## Static information about a card (eg. base atk, ability)
var info: CardStats

var current_slot: CardSlot

#region STATUS
var summon_sickness := false:
	get:
		if not owned_by_player:
			assert(false, "Attribute summon_sickness not implemented for enemy cards")
		return summon_sickness

var placement := Placement.DECK:
	get:
		if not owned_by_player:
			assert(false, "Attribute placement not implemented for enemy cards")
		return placement
var mouse_over := false
var selected := false
# Card is sealed at any level higher then 0.

var dont_show_view := false
#endregion

#region TWEENS AND POSITION
var anchor_position: Vector2
var hover_tween: Tween
var unhover_tween: Tween
var button_y_pos: float
var movement_tween: Tween
#endregion


static func create_card(parent_scene: Node2D, id: int) -> Card:
	var new_card: Card = load("res://scenes/game/card.tscn").instantiate()
	var card_info: CardStats = CardStatsManager.card_info_dict[id]

	parent_scene.add_child(new_card)

	new_card.state = CardState.fromCardStats(id, card_info)
	new_card.info = card_info
	new_card.card_sprite.texture = load(card_info.graphics)

	return new_card


func _ready() -> void:
	Global.mouse_input_functions.append(_on_mouse_clicked)
	VerifyClientAction.player_finished.connect(_on_player_finished)
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)
	button_y_pos = buttons.position.y


func reset_variables() -> void:
	if owned_by_player:
		summon_sickness = false
		state.phase = TurnPhase.MoveOrAction
	mouse_over = false
	selected = false


func _on_mouse_clicked() -> void:
	for button in buttons.get_children():
		if button.mouse_over:
			return

	if owned_by_player:
		if mouse_over and not selected:
			if placement == Placement.HAND:
				Global.hand_card_selected.emit(self)
			elif placement == Placement.PLAYMAT:
				Global.playmat_card_selected.emit(self)
		elif selected:
			if placement == Placement.HAND:
				Global.hand_card_unselected.emit(self)
			elif placement == Placement.PLAYMAT:
				Global.playmat_card_unselected.emit(self)
	else:
		if mouse_over and not selected:
			if dont_show_view:
				dont_show_view = false
			else:
				selected = true
				show_buttons([MatchManager.Actions.VIEW])
		elif selected:
			selected = false
			hide_buttons()


func _on_player_finished() -> void:
	if owned_by_player:
		summon_sickness = false
		state.phase = TurnPhase.MoveOrAction
		if state.sealed_turns_left > 0:
			state.sealed_turns_left -= 1
		if state.sealed_turns_left == 0:
			seal_sprite.visible = false


func _on_opponent_finished() -> void:
	if not owned_by_player:
		if state.sealed_turns_left > 0:
			state.sealed_turns_left -= 1
		if state.sealed_turns_left == 0:
			seal_sprite.visible = false


func select() -> void:
	selected = true

	if hover_tween:
		hover_tween.kill()
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 1.0, 0.5)

	if unhover_tween:
		unhover_tween.kill()
	unhover_tween = get_tree().create_tween()
	unhover_tween.tween_property(card_unhover_sprite, "modulate:a", 0.0, 0.5)

	atk_label.text = str(info.base_atk)
	hp_label.text = str(state.health)


func unselect() -> void:
	selected = false

	if hover_tween:
		hover_tween.kill()
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 0.0, 0.5)

	if unhover_tween:
		unhover_tween.kill()
	unhover_tween = get_tree().create_tween()
	unhover_tween.tween_property(card_unhover_sprite, "modulate:a", 1.0, 0.5)


func show_buttons(actions: Array) -> void:
	buttons.visible = true
	buttons.position.y = button_y_pos - actions.size() * 13

	var shortcut_strings = []

	for button in buttons.get_children():
		if button.button_action in actions:
			button.visible = true
			match button.button_action:
				MatchManager.Actions.SUMMON:
					shortcut_strings.append("S: Summon, ")
				MatchManager.Actions.SWITCH:
					shortcut_strings.append("W: Switch, ")
				MatchManager.Actions.ATTACK:
					shortcut_strings.append("A: Attack, ")
				MatchManager.Actions.ABILITY:
					shortcut_strings.append("E: Ability, ")
				MatchManager.Actions.VIEW:
					shortcut_strings.append("V: View, ")
		else:
			button.visible = false

	Global.show_shortcuts.emit(shortcut_strings)


func hide_buttons() -> void:
	Global.hide_shortcuts.emit()
	buttons.visible = false


func move_and_reanchor(pos: Vector2):
	anchor_position = pos
	visually_move_card(anchor_position)


func visually_move_card(end_pos: Vector2, time := 0.5):
	if movement_tween:
		movement_tween.kill()

	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "position", end_pos, time)

	await get_tree().create_timer(0.01).timeout
	MatchManager.input_paused = true
	await get_tree().create_timer(time).timeout
	MatchManager.input_paused = false


func set_slot(slot: CardSlot):
	assert(current_slot == null)
	current_slot = slot
	slot.stored_card = self


func remove_from_slot():
	assert(current_slot != null)
	current_slot.stored_card = null
	current_slot = null


func set_shield(num_turns: int):
	state.shield = num_turns
	shield_sprite.visible = num_turns > 0


func do_damage(amount: int):
	assert(amount >= 0)

	if state.shield > 0:
		state.shield -= 1

		if state.shield == 0:
			shield_sprite.visible = false
		return

	state.health -= amount
	if state.health <= 0:
		Global.player_field.destroy_card(current_slot.slot_no, self)

	render_attack(state.health)


func heal(amount: int):
	assert(amount > 0)
	state.health += amount  # not capped by design


## By default sets z index to 0
func set_card_visibility(index := 0):
	z_index = index


func shift_card_y(amount: float, time := 0.1):
	if movement_tween:
		movement_tween.kill()
	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "position:y", anchor_position.y + amount, time)


func flip_card(enemy := false) -> void:
	if not enemy:
		animation_player.play("flip")
	else:
		animation_player.play("flip_enemy")


func render_attack(_hp: int) -> void:
	animation_player.play("nuke")


func _on_mouse_hover():
	mouse_over = true


func _on_mouse_exit():
	mouse_over = false
