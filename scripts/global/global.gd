# Global stuffs for game functionality 
extends Node 

# FROM CARD
signal hand_card_selected(card: Card)
signal hand_card_unselected(card: Card)
signal playmat_card_selected(card: Card)
signal playmat_card_unselected(card: Card)

# FROM SLOT
signal slot_chosen(slot_no: int, card: Card)
signal enemy_slot_chosen(slot_no: int, card: Card)

# TO SLOT
signal fill_slot(slot_no: int, card: Card)
signal unfill_slot(slot_no: int, card: Card)

# TO ENEMY CARD SLOTS 
signal highlight_enemy_cards(card: Card, atk_range: CardStats.AttackRange)
signal unhighlight_enemy_cards(card: Card)

# TO PLAYER CARD SLOTS 
signal show_slots(flag: bool)

# TO HUD
signal show_shortcuts(shortcuts: PackedStringArray)
signal hide_shortcuts
signal notice(msg: String)

# TO RAM 
signal update_ram(value: int)
signal update_max_ram(value: int)
signal update_enemy_ram(value: int)
signal update_enemy_max_ram(value: int)

# TO RAM MANAGER
signal use_ram(value: int)

# TO CARD VIEWER 
signal close_view 

## Simple mouse input implementation 
## All functions that process mouse input 
## should be appended to the array
## This is done so that mouse input can be 
## proccessed in a controlled manner
## Current order is SLOTS -> CARDS 
var mouse_input_functions: Array[Callable] = []

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("click"):
		for callable in mouse_input_functions:
			callable.call()
