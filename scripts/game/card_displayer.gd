extends Node2D

var tween: Tween 

@onready var display = $Sprite2D

var current_displaid_card: Card

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.display_card.connect(_on_display_card)
	Global.hide_card.connect(_on_hide_card)

func _on_display_card(card: Card) -> void:
	#TODO: When card types are implemented set sprite using the card 
	display.show() 
	current_displaid_card = card 
	 
func _on_hide_card(card: Card) -> void:
	if current_displaid_card == card: 
		display.hide()  
