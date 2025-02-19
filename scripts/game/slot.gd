class_name CardSlot
extends Node2D

@export var enemy := false
@export var slot_no: int

@onready var sprite_2d: Sprite2D = $Sprite2D

var stored_card: Card = null
var mouse_over := false


func _ready() -> void:
	Global.mouse_input_functions.append(_on_mouse_clicked)

	if enemy:
		sprite_2d.texture = preload("res://assets/game/CardSlotHighlightRed.png")


func _on_mouse_clicked() -> void:
	if MatchManager.input_paused or MatchManager._opponent_turn:
		return

	if mouse_over:
		if enemy:
			Global.enemy_slot_chosen.emit(slot_no, stored_card)
		else:
			Global.slot_chosen.emit(slot_no, stored_card)


func _on_area_2d_mouse_entered() -> void:
	mouse_over = true


func _on_area_2d_mouse_exited() -> void:
	mouse_over = false


func _on_tree_exiting() -> void:
	Global.mouse_input_functions.erase(_on_mouse_clicked)
