extends Node2D
class_name Field

@export var player_field: Field
@export var enemy_field: Field  

func switch_cards(card1: Card, card2: Card) -> void:
	# Change slots 
	var card1_slot = get_slot_no(card1)
	var card2_slot = get_slot_no(card2)
	
	Global.fill_slot.emit(card1_slot, card2) 
	Global.fill_slot.emit(card2_slot, card1)
	
	# Change visuals 
	var card1_pos = card1.global_position 
	var card2_pos = card2.global_position 
	
	card1.move_card(card2_pos)
	card2.move_card(card1_pos) 

## Return true if a target slot is reachable by given card 
## NOTE: Field Independent
func slot_is_reachable(target_slot_no, atk_card: Card, atk_is_from_player: bool) -> bool:
	var atk_front_row
	var atk_back_row
	var target_front_row
	var target_back_row 
	var atk_slot_no 
	
	if atk_is_from_player:
		atk_front_row = Global.PLAYER_FRONT_ROW
		atk_back_row = Global.PLAYER_BACK_ROW 
		target_front_row = Global.ENEMY_FRONT_ROW
		target_back_row = Global.ENEMY_BACK_ROW
		
		atk_slot_no = player_field.get_slot_no(atk_card)
	else:
		atk_front_row = Global.ENEMY_FRONT_ROW 
		atk_back_row = Global.ENEMY_BACK_ROW
		target_front_row = Global.PLAYER_FRONT_ROW
		target_back_row = Global.PLAYER_BACK_ROW 
		
		atk_slot_no = enemy_field.get_slot_no(atk_card)
	
	if atk_slot_no in atk_front_row: 
		if target_slot_no in target_front_row: 
			return true  
		elif target_slot_no in target_back_row:  
			if atk_card.card_info.attack_range == CardStats.AttackRange.REACH:
				return true 
			else: 
				if slots_empty(target_front_row):
					return true 
				else:
					return false  
	elif atk_slot_no in atk_back_row:   
		if target_slot_no in target_front_row: 
			if atk_card.card_info.attack_range == CardStats.AttackRange.REACH:
				return true 
			else:
				if slots_empty(atk_front_row):
					return true 
				else:
					return false 
		elif target_slot_no in target_back_row:
			return false  
	
	assert(false, "Someone tell Kotge there is a problem with the slot_is_reacheable function")
	return false 

## Returns true if a list of slots are empty 
## Takes a list of slot numbers 
## NOTE: Field Independent
func slots_empty(slot_nos) -> bool:
	for no in slot_nos: 
		if no in Global.PLAYER_ROWS:
			var slot = player_field.get_node("Slot%d" % no)
			if slot.stored_card:
				return false
		else: 
			var slot = enemy_field.get_node("Slot%d" % no)
			if slot.stored_card:
				return false
	return true 

## Returns slot number of card 
## Returns 0 if card isn't in any slot 
## WARNING: Field dependent. Will only check the current field 
func get_slot_no(card: Card) -> int:
	for slot in get_children(): 
		if slot.stored_card == card:
			return slot.slot_no
	return 0  

## Returns position of card in array form 
## WARNING: Field dependent. Will only check the current field 
func get_slot_array(card: Card) -> Array:
	return convert_to_array(get_slot_no(card))

## Returns the Vector2 position of slot  
## WARNING: Field dependent. Will only check the current field 
func get_slot_pos(slot_no: int) -> Vector2: 
	var pos = get_node("Slot" + str(slot_no)).global_position 
	return pos

#region STATIC FUNCTIONS 
static func convert_to_array(index: int) -> Array:
	assert(index != 0, "There is no 0 slot")
	
	if index <= 4: 
		return [0, index-1]
	elif index <= 7: 
		return [1, index-5]
	elif index <= 10:
		return [1, 2-(index-8)]
	elif index <= 14:
		return [0, 3-(index-11)]
	
	return []

static func convert_to_index(array: Array, enemy := false) -> int:
	if not enemy: 
		match array:
			[0,0]:
				return 1 
			[0,1]:
				return 2
			[0,2]:
				return 3
			[0,3]:
				return 4
			[1,0]:
				return 5
			[1,1]:
				return 6 
			[1,2]:
				return 7
	else:
		match array:
			[1,2]:
				return 8
			[1,1]:
				return 9
			[1,0]:
				return 10
			[0,3]:
				return 11
			[0,2]:
				return 12
			[0,1]:
				return 13
			[0,0]:
				return 14 

	return 0 
#endregion 

