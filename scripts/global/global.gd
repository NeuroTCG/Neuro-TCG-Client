# Global stuffs for game functionality
extends Node

const PLAYER_FRONT_ROW = [1, 2, 3, 4]
const PLAYER_BACK_ROW = [5, 6, 7]
const PLAYER_ROWS = [1, 2, 3, 4, 5, 6, 7]
const ENEMY_FRONT_ROW = [11, 12, 13, 14]
const ENEMY_BACK_ROW = [8, 9, 10]
const ENEMY_ROWS = [8, 9, 10, 11, 12, 13, 14]

# FROM CARD
# TODO: preferably remove all of this

signal hand_card_selected(card: Card)
signal hand_card_unselected(card: Card)
signal playmat_card_selected(card: Card)
signal playmat_card_unselected(card: Card)

# FROM SLOT
signal slot_chosen(slot_no: int, card: Card)
signal enemy_slot_chosen(slot_no: int, card: Card)

# TO ENEMY FIELD
signal show_enemy_slots_for_attack(card: Card)
signal hide_enemy_cards

# TO PLAYER FIELD
signal show_player_slots_for_summon
signal hide_player_slots

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


signal network_manager_ready
var network_manager: NetworkManager = null

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
