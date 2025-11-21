extends Node2D

var tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var description: RichTextLabel = $Description


func _ready() -> void:
	MatchManager.action_view.connect(_on_view)
	Global.close_view.connect(_on_close_view)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		visible = false


func _on_view(card: Card) -> void:
	visible = true
	if ResourceLoader.exists(card.info.graphics):
		sprite.texture = card.card_sprite.texture
	else:
		sprite.texture = load("res://assets/game/cards/template.png")

	description.text = (
		"Card Name: %s \nHP: %d \nAtk: %d \nSummon Cost: %d\nAbility Cost: %d"
		% [
			card.info.name,
			card.state.health,
			card.current_attack_value,
			card.info.cost,
			card.info.ability.cost
		]
	)


func _on_close_view() -> void:
	visible = false
