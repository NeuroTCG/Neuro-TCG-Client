extends Node2D
class_name Card

@onready var animation_player := $AnimationPlayer
@onready var card_hover_sprite = $CardBack/CardHover
@onready var card_unhover_sprite = $CardBack/CardUnhover
@onready var collision = $Area2D/CollisionShape2D
@onready var card_sprite = $CardBack/CardFront
@onready var attack_sprite = $AttackSprite
@onready var buttons = %Buttons

#region CARD ATTRIBUTES
var card_name: String
var id: int
var health: float
var attack: float
var attack_m1: float
var placement: Placement
#endregion

var mouse_over := false
var selected := false
var anchor_position: Vector2
var hover_tween: Tween
var unhover_tween: Tween
var button_y_pos: float
var movement_tween: Tween
var card_info: CardInfo

enum Placement {
	DECK,
	HAND,
	PLAYMAT,
	ENEMY
}

static func create_card(parent_scene: Node2D, id: int) -> Card:
	var new_card: Card = load("res://scenes/game/card.tscn").instantiate()
	var card_info: CardInfo = CardInfoManager.card_info_dict[id]
	
	parent_scene.add_child(new_card)
	
	new_card.id = id
	new_card.card_info = card_info
	new_card.card_sprite.texture = card_info.graphics
	
	new_card.placement = Placement.DECK
	
	return new_card

func _ready() -> void:
	Global.mouse_input_functions.append(_on_mouse_clicked)
	button_y_pos = buttons.position.y

func _on_mouse_clicked() -> void:
	if MatchManager.input_paused:
		return
	
	for button in buttons.get_children():
		if button.mouse_over:
			return
	
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

func select() -> void:
	selected = true
	
	if hover_tween: hover_tween.kill()
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 1.0, 0.5)
	
	if unhover_tween: unhover_tween.kill()
	unhover_tween = get_tree().create_tween()
	unhover_tween.tween_property(card_unhover_sprite, "modulate:a", 0.0, 0.5)

func show_buttons(actions: Array) -> void:
	buttons.visible = true
	buttons.position.y = button_y_pos - actions.size() * 13
	
	var shortcut_strings = []
	
	for button in buttons.get_children():
		if button.button_action in actions:
			button.visible = true
			print(button.button_action)
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

func unselect() -> void:
	selected = false
	
	if hover_tween: hover_tween.kill()
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 0.0, 0.5)

	if unhover_tween: unhover_tween.kill()
	unhover_tween = get_tree().create_tween()
	unhover_tween.tween_property(card_unhover_sprite, "modulate:a", 1.0, 0.5)

func move_card(end_pos: Vector2, anchor:=false, time:=0.5):
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
func set_card_visibility(index:=0):
	z_index = index

func shift_card_y(amount: float, time:=0.1):
	if movement_tween:
		movement_tween.kill()
	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "position:y", anchor_position.y + amount, time)

func flip_card(enemy:=false) -> void:
	if not enemy:
		animation_player.play("flip")
	else:
		animation_player.play("flip_enemy")

func render_attack() -> void:
	animation_player.play("nuke")

func destroy() -> void:
	# TODO: figure out how to not leave nulls everwhere
	await animation_player.animation_finished
	Global.mouse_input_functions.erase(_on_mouse_clicked)
	queue_free()

func _on_mouse_hover():
	mouse_over = true

func _on_mouse_exit():
	mouse_over = false

	
