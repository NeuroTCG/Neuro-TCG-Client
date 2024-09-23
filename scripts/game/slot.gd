extends Node2D

@export var enemy := false
@export var slot_no: int

@onready var sprite_2d = $Sprite2D

var stored_card = null
var mouse_over := false


func _ready() -> void:
	Global.fill_slot.connect(_on_fill_slot)
	Global.unfill_slot.connect(_on_unfill_slot)
	Global.mouse_input_functions.append(_on_mouse_clicked)

	if enemy:
		sprite_2d.texture = preload("res://assets/game/CardSlotHighlightRed.png")


func _on_fill_slot(slot_no: int, card: Card) -> void:
	if slot_no != self.slot_no:
		return

	stored_card = card


func _on_unfill_slot(slot_no: int, card: Card) -> void:
	if slot_no != self.slot_no:
		return

	stored_card = null


func _on_mouse_clicked():
	if MatchManager.input_paused or MatchManager._opponent_turn:
		return

	if mouse_over:
		if enemy:
			Global.enemy_slot_chosen.emit(slot_no, stored_card)
		else:
			Global.slot_chosen.emit(slot_no, stored_card)


func _on_area_2d_mouse_entered():
	mouse_over = true


func _on_area_2d_mouse_exited():
	mouse_over = false
