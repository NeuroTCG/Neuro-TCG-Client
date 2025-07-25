# Global stuffs for game functionality
extends Node

const PLAYER_FRONT_ROW: Array[int] = [1, 2, 3, 4]
const PLAYER_BACK_ROW: Array[int] = [5, 6, 7]
const PLAYER_ROWS: Array[int] = [1, 2, 3, 4, 5, 6, 7]
const ENEMY_FRONT_ROW: Array[int] = [11, 12, 13, 14]
const ENEMY_BACK_ROW: Array[int] = [8, 9, 10]
const ENEMY_ROWS: Array[int] = [8, 9, 10, 11, 12, 13, 14]

# FROM CARD

signal hand_card_selected(card: Card)
signal hand_card_unselected(card: Card)
signal playmat_card_selected(card: Card)
signal playmat_card_unselected(card: Card)

# FROM SLOT
signal slot_chosen(slot_no: int, card: Card)
signal enemy_slot_chosen(slot_no: int, card: Card)

# TO ENEMY FIELD
signal show_enemy_slots_for_attack(card: Card)
signal show_enemy_slots_for_magic
signal hide_enemy_cards

# TO PLAYER FIELD
signal show_player_slots_for_summon
signal show_player_slots_for_magic
signal hide_player_slots

# TO HUD
signal show_shortcuts(shortcuts: PackedStringArray)
signal hide_shortcuts
signal notice(msg: String)

# TO RAM
signal player_ram_changed(value: int)
signal update_max_ram(value: int)
signal enemy_ram_changed(value: int)
signal update_enemy_max_ram(value: int)

# TO RAM MANAGER
signal use_ram(value: int)
signal use_enemy_ram(value: int)

# TO CARD VIEWER
signal close_view

# TO DECK MASTER SELECT
signal card_info_received

signal network_manager_ready
var network_manager: NetworkManager = null

var player_field: PlayerField = null
var enemy_field: EnemyField = null
var player_hand: PlayerHand = null
var enemy_hand: EnemyHand = null

var ram_manager: RamManager = null

#The card the player has currently selected.
var selected_card: Card = null
var selected_card_from_hand = false

#When true, prevents the player from selecting another card.
var card_select_locked = false


func unselect_card():
	selected_card = null
	card_select_locked = false
	selected_card_from_hand = false


## Simple mouse input implementation
## All functions that process mouse input
## should be appended to the array
## This is done so that mouse input can be
## proccessed in a controlled manner
## Current order is SLOTS -> CARDS
var mouse_input_functions: Array[Callable] = []

var game_over_template = preload("res://scenes/ui/game_over.tscn")


func reset_values():
	Global.card_select_locked = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		for callable in mouse_input_functions:
			callable.call()
