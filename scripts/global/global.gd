## For global signals 
extends Node

var input_paused = false 

# HAND TO OTHER 
signal hand_card_selected(card: Card)
signal hand_card_unselected(card: Card)

# SLOT TO OTHER 
signal slot_chosen(slot_no: int, card: Card)
signal playmat_card_selected(card: Card)
signal playmat_card_unselected(card: Card)

# OTHER TO SLOT 
signal fill_slot(slot_no: int, card: Card)
signal unfill_slot(slot_no: int)
signal show_slots(flag: bool)


