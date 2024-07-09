## Signal bus for game functionality 
extends Node

# FROM CARD
signal hand_card_selected(card: Card)
signal hand_card_unselected(card: Card)
signal playmat_card_selected(card: Card)
signal playmat_card_unselected(card: Card)

# FROM SLOT
signal slot_chosen(slot_no: int, card: Card)

# TO SLOT
signal fill_slot(slot_no: int, card: Card)
signal unfill_slot(slot_no: int, card: Card)

# TO ENEMY CARD SLOTS 
signal highlight_enemy_cards(card: Card)
signal unhighlight_enemy_cards(card: Card)

# TO PLAYER CARD SLOTS 
signal show_slots(flag: bool)

## Simple mouse input implementation 
## This is done so that mouse input is only registered once and
## activated in a controlled manner 
## all functions that process mouse input should be added 
## to the following array 
var mouse_input_functions = [] 

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"): 
		for callable in mouse_input_functions: 
			print(callable)
			callable.call() 
