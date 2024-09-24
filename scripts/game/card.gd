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

#region IMUTABLE CARD STATS
# TODO: remove
var owned_by_player := true

var state: CardState
var info: CardStats
#endregion

#region STATUS
var summon_sickness := false:
	get:
		if not owned_by_player:
			assert(false, "Attribute summon_sickness not implemented for enemy cards")
		return summon_sickness
## Phase 2 -> Movement & Action allowed
## Phase 1 -> Action allowed
## Phase 0 -> Only view allowed
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


# TODO: remove or make it update the slot
# TODO: don't pass in anchor, whatever that does
func move_card(end_pos: Vector2, anchor := false, time := 0.5):
	if movement_tween:
		movement_tween.kill()
	if anchor:
		anchor_position = end_pos
	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "position", end_pos, time)

	await get_tree().create_timer(0.01).timeout
	MatchManager.input_paused = true
	await get_tree().create_timer(time).timeout
	MatchManager.input_paused = false


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


# TODO: remove or make it not change stuff
func render_attack_with_atk_value(atk_value: int) -> void:
	if state.shield > 0:
		state.shield -= 1
		return

	state.health -= atk_value
	animation_player.play("nuke")


# TODO: remove or make it not change stuff
func render_attack(_hp: int) -> void:
	state.health = _hp
	animation_player.play("nuke")


func _on_mouse_hover():
	mouse_over = true


func _on_mouse_exit():
	mouse_over = false
