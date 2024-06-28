extends Node2D

var tween: Tween 

@onready var display = $Sprite2D

var current_displaid_card: Card

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hand_card_selected.connect(_on_hand_card_selected)
	Global.hand_card_unselected.connect(_on_hand_card_unselected)

func _on_hand_card_selected(card: Card) -> void:
	#TODO: When card types are implemented set sprite using the card 
	display.show() 
	current_displaid_card = card 
	 
func _on_hand_card_unselected(card: Card) -> void:
	if card == current_displaid_card:
		display.hide()  
