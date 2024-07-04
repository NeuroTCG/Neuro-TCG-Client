extends Node2D
class_name Card 

@onready var animation_player = $AnimationPlayer
@onready var card_hover_sprite = $CardBack/CardHover
@onready var collision = $Area2D/CollisionShape2D

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

enum Placement {
	DECK,  # Place in deck anytime you don't want the card to interact with mouse 
	HAND,
	PLAYMAT
}

static func create_card(card_name: String, id: int, health: float, attack: float, attack_m1: float) -> Card:
	var new_card: Card = load("res://scenes/game/card.tscn").instantiate() 
	new_card.card_name = card_name
	new_card.id = id
	new_card.health = health
	new_card.attack = attack
	new_card.attack_m1 = attack_m1
	new_card.placement = Placement.DECK
	
	return new_card

func _process(delta: float) -> void:
	if Global.input_paused:
		return 
	
	if Input.is_action_just_pressed("click"):
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

func unselect() -> void: 
	selected = false 
	if hover_tween: hover_tween.kill() 
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 0.0, 0.5)

func move_card(end_pos: Vector2, anchor:= false, time := 0.5):
	if anchor: 
		anchor_position = end_pos 
	var tween = get_tree().create_tween() 
	Global.input_paused = true 
	await tween.tween_property(self, "position", end_pos, time).finished
	Global.input_paused = false 

func shift_card_y(amount: float, time := 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", anchor_position.y + amount, time)

func flip_card() -> void:
	animation_player.play("flip")

func _on_mouse_hover():
	mouse_over = true 

func _on_mouse_exit():
	mouse_over = false 

