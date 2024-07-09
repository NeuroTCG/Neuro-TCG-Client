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

# Simple mouse input implementation 
signal mouse_clicked

