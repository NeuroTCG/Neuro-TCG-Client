extends Node2D

@export var slot_no: int 

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Global.slot_chosen.emit(slot_no) 
