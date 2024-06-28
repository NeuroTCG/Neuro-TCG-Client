extends Node2D
 
func _ready() -> void:
	Global.show_slot.connect(show_slots)

func get_slot_pos(slot_no: int) -> Vector2: 
	return get_node("Slot" + str(slot_no)).global_position 
	
func show_slots(flag: bool) -> void:
	if flag:
		visible = true 
	else:
		visible = false




