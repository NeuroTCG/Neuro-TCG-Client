extends Node2D

var tween: Tween

@onready var sprite = $Sprite2D
@onready var description = $Description


func _ready():
	MatchManager.action_view.connect(_on_view)
	Global.close_view.connect(_on_close_view)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		visible = false


func _on_view(card: Card) -> void:
	visible = true
	sprite.texture = card.card_sprite.texture
	description.text = (
		"Card Name: \nHP: %d \nAtk: %d \nCost: %d"
		% [card.state.health, card.info.base_atk, card.info.cost]
	)


func _on_close_view() -> void:
	visible = false
