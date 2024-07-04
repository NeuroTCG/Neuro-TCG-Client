extends Node2D

@export var slot_no: int 

var stored_card = null 

func _ready() -> void: 
	Global.fill_slot.connect(_on_fill_slot)
	Global.unfill_slot.connect(_on_unfill_slot)

func _on_fill_slot(slot_no: int, card: Card) -> void:
	if slot_no != self.slot_no:
		return 

	stored_card = card  

func _on_unfill_slot(slot_no: int) -> void:
	if slot_no != self.slot_no:
		return 
		
	stored_card = null 

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Global.input_paused:
		return 
	
	if event.is_action_pressed("click"):
		Global.slot_chosen.emit(slot_no, stored_card) 
