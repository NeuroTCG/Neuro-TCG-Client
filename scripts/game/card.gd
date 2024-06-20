extends Node2D
class_name Card 

const card_scene: PackedScene = preload("res://scenes/game/card.tscn")

var card_name: String 
var id: int 
var health: float 
var attack: float
var attack_m1: float 

static func create_card(card_name: String, id: int, health: float, attack: float, attack_m1: float) -> Card:
	var new_card: Card = card_scene.instantiate() 
	new_card.card_name = card_name
	new_card.id = id
	new_card.health = health
	new_card.attack = attack
	new_card.attack_m1 = attack_m1
	
	return new_card
