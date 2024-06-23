extends Node2D
class_name Card 

@onready var animation_player = $AnimationPlayer

#region CARD ATTRIBUTES
var card_name: String 
var id: int 
var health: float 
var attack: float
var attack_m1: float 
var placement: Placement 
#endregion

enum Placement {
	DECK,
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

func move_card(end_pos: Vector2, time := 0.5) -> void:
	var tween = get_tree().create_tween() 
	await tween.tween_property(self, "position", end_pos, time)

func flip_card() -> void:
	animation_player.play("flip")

func _on_mouse_hover():
	pass # Replace with function body.
