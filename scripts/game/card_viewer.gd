extends Node2D

var tween: Tween 

@onready var sprite = $Sprite2D

func _ready():
	Global.view_card.connect(_on_view)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		visible = false 
	
func _on_view(card: Card) -> void:
	visible = true 
	sprite.texture = card.card_sprite.texture

