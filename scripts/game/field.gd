extends Node2D
class_name Field

## Returns slot number of card 
## Returns 0 if card isn't in any slot 
func get_slot_no(card: Card) -> int:
	for slot in get_children(): 
		if slot.stored_card == card:
			return slot.slot_no
	return 0  

func get_slot_array(card: Card) -> Array:
	return convert_to_array(get_slot_no(card))

func get_slot_pos(slot_no: int) -> Vector2: 
	var pos = get_node("Slot" + str(slot_no)).global_position 
	return pos

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

## Return true if an opponent slot is reachable by the player card 
## Takes opponent slot and atk_range of player card
func opponent_is_reachable(slot, atk_range: CardStats.AttackRange) -> bool:
	if slot.slot_no in [8, 9, 10]:  # For cards in the back 
		if atk_range == CardStats.AttackRange.REACH:  
			return true
		else:  # Without reach, the front row cards must be empty 
			if slots_empty([11, 12, 13, 14]):
				return true 
			return false  
	else:  # Cards in the front are always reachable 
		return true   

## Return true if a player slot is reachable by the opponent card 
## Takes player slot and atk_range of opponent card 
func player_is_reachable(slot, atk_range: CardStats.AttackRange) -> bool:
	if slot.slot_no in [5, 6, 7]:  # For cards in the back 
		if atk_range == CardStats.AttackRange.REACH:  
			return true
		else:  # Without reach, the front row cards must be empty 
			if slots_empty([1, 2, 3, 4]):
				return true 
			return false  
	else:  # Cards in the front are always reachable 
		return true   

## Returns true if a list of slots are empty 
## Takes a list of slot numbers 
func slots_empty(slot_nos: Array[int]) -> bool:
	for no in slot_nos: 
		var slot = get_node("Slot%d" % no)
		if slot.stored_card:
			return false
	return true 

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

