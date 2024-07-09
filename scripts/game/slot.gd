extends Node2D

@export var enemy := false 
@export var slot_no: int 

@onready var sprite_2d = $Sprite2D

var stored_card = null 

func _ready() -> void: 
	Global.fill_slot.connect(_on_fill_slot)
	Global.unfill_slot.connect(_on_unfill_slot)
	
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

func _on_area_2d_input_event(viewport, event, shape_idx):
	if MatchManager.input_paused:
		return 
	
	if event.is_action_pressed("click"):
		if enemy:
			if stored_card:
				stored_card.attack_card() 
		else:
			Global.slot_chosen.emit(slot_no, stored_card) 
