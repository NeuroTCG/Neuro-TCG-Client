extends Node2D

var tween: Tween

@onready var sprite = $Sprite2D

var current_displaid_card: Card


func _ready():
	Global.hand_card_selected.connect(_on_card_selected)
	Global.hand_card_unselected.connect(_on_card_unselected)


func _on_card_selected(card: Card) -> void:
	show()
	sprite.texture = card.card_sprite.texture
	current_displaid_card = card


func _on_card_unselected(card: Card) -> void:
	if card == current_displaid_card:
		hide()
