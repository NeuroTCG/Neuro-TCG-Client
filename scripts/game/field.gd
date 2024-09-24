extends Node2D
class_name Field

@export var player_field: Field
@export var enemy_field: Field


func get_slot(slot: int) -> CardSlot:
	var player_slot = player_field.get_node_or_null("Slot" + str(slot))
	var enemy_slot = enemy_field.get_node_or_null("Slot" + str(slot))

	if player_slot != null:
		return player_slot

	assert(enemy_slot != null, "Slot nr. %d wasn't found" % slot)
	return enemy_slot


## Swaps two cards. or a card and an emoty slot
func switch_cards(slot_no1: int, slot_no2: int) -> void:
	# Change slots
	var slot1 := get_slot(slot_no1)
	var slot2 := get_slot(slot_no2)

	var card1 := slot1.stored_card
	var card2 := slot2.stored_card

	# TODO: figure out if these are needed to prevent wrong usage.
	if card1 == null:
		assert(card2 != null)
	if card2 == null:
		assert(card1 != null)

	if card2 != null:
		card2.remove_from_slot()
		card2.set_slot(slot1)

		card2.move_and_reanchor(slot1.global_position)
	if card1 != null:
		card1.remove_from_slot()
		card1.set_slot(slot2)

		card1.move_and_reanchor(slot2.global_position)


func move_card(from: int, to: int) -> void:
	var from_slot := get_slot(from)
	var to_slot := get_slot(to)

	var card = from_slot.stored_card
	assert(
		to_slot.stored_card == null,
		"tried to move a card onto another one; use switch_cards to swap them"
	)

	card.remove_from_slot()
	card.set_slot(to_slot)

	card.move_and_reanchor(to_slot.global_position)


## Return true if a target slot is reachable by given card
## NOTE: Field Independent
# TODO: maybe rewrite to match the server style
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
			if atk_card.info.attack_range == CardStats.AttackRange.REACH:
				return true
			else:
				if slots_empty(target_front_row):
					return true
				else:
					return false
	elif atk_slot_no in atk_back_row:
		if target_slot_no in target_front_row:
			if atk_card.info.attack_range == CardStats.AttackRange.REACH:
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
# TODO: typo
func slots_empty(slot_nos) -> bool:
	for no in slot_nos:
		if no in Global.PLAYER_ROWS:
			# TODO: don't manually get from slot
			var slot = player_field.get_node("Slot%d" % no)
			if slot.stored_card:
				return false
		else:
			# TODO: don't manually get from slot
			var slot = enemy_field.get_node("Slot%d" % no)
			if slot.stored_card:
				return false
	return true


## Returns slot number of card
## Returns 0 if card isn't in any slot
## WARNING: Field dependent. Will only check the current field
func get_slot_no(card: Card) -> int:
	return card.current_slot.slot_no


## Returns position of card in array form
## WARNING: Field dependent. Will only check the current field
func get_slot_array(card: Card) -> Array:
	return convert_to_array(get_slot_no(card))


## Returns the Vector2 position of slot
## WARNING: Field dependent. Will only check the current field
# TODO: remove, because only used for stupid things
func get_slot_pos(slot_no: int) -> Vector2:
	# TODO: don't manually get from slot
	return get_slot(slot_no).global_position


#region STATIC FUNCTIONS
static func convert_to_array(index: int) -> Array:
	assert(index > 0 && index <= 14, "Index is only defined from 1 to 14, not %d" % index)

	if index <= 4:
		return [0, index - 1]
	elif index <= 7:
		return [1, index - 5]
	elif index <= 10:
		return [1, 2 - (index - 8)]
	elif index <= 14:
		return [0, 3 - (index - 11)]

	assert(false, "Something has gone very very wrong.")
	return []


# TODO: split in two or remove completely
static func convert_to_index(array: Array, enemy := false) -> int:
	if not enemy:
		match array:
			[0, 0]:
				return 1
			[0, 1]:
				return 2
			[0, 2]:
				return 3
			[0, 3]:
				return 4
			[1, 0]:
				return 5
			[1, 1]:
				return 6
			[1, 2]:
				return 7
	else:
		match array:
			[1, 2]:
				return 8
			[1, 1]:
				return 9
			[1, 0]:
				return 10
			[0, 3]:
				return 11
			[0, 2]:
				return 12
			[0, 1]:
				return 13
			[0, 0]:
				return 14

	return 0
#endregion
