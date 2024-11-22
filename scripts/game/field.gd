extends Node2D
class_name Field

var destroyed_cards: Array[Card] = []

@export var player_field: Field
@export var enemy_field: Field

signal on_card_destroyed(slot: int, card: Card)

enum Side {
	Player,
	Enemy,
}

enum RowPositions {
	UNKNOWN = -1,
	FRONT = 0,
	BACK = 1,
}


## searches both fields for the slot, so it doesn't matter which side is used
func get_slot(slot: int) -> CardSlot:
	var player_slot: CardSlot = player_field.get_node_or_null("Slot" + str(slot))
	var enemy_slot: CardSlot = enemy_field.get_node_or_null("Slot" + str(slot))

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

	var card := from_slot.stored_card
	assert(
		to_slot.stored_card == null,
		"tried to move a card onto another one; use switch_cards to swap them"
	)

	card.remove_from_slot()
	card.set_slot(to_slot)

	card.move_and_reanchor(to_slot.global_position)


func get_row_for_card_slot(slot_no: int) -> RowPositions:
	if slot_no in Global.PLAYER_FRONT_ROW or slot_no in Global.ENEMY_FRONT_ROW:
		return RowPositions.FRONT
	elif slot_no in Global.PLAYER_BACK_ROW or slot_no in Global.ENEMY_BACK_ROW:
		return RowPositions.BACK

	assert(false, "slot_no isn't valid for a call to get_row_for_card_slot")
	return RowPositions.UNKNOWN


## Return true if a target slot is reachable by given card
## NOTE: Field Independent
func slot_is_reachable(target_slot_no: int, atk_card: Card) -> bool:
	var atk_slot_no := get_slot_no(atk_card)

	var is_player_front_empty := slots_empty(Global.PLAYER_FRONT_ROW)
	var is_opponent_front_empty := slots_empty(Global.ENEMY_FRONT_ROW)

	var attacker_reach := atk_card.info.attack_range

	var atk_row := get_row_for_card_slot(atk_slot_no)
	var target_row := get_row_for_card_slot(target_slot_no)

	match [atk_row, target_row]:
		[RowPositions.FRONT, RowPositions.FRONT]:
			return true
		[RowPositions.FRONT, RowPositions.BACK]:
			return is_opponent_front_empty || attacker_reach == CardStats.AttackRange.REACH
		[RowPositions.BACK, RowPositions.FRONT]:
			return is_player_front_empty || attacker_reach == CardStats.AttackRange.REACH
		[RowPositions.BACK, RowPositions.BACK]:
			return attacker_reach == CardStats.AttackRange.REACH
		_:
			assert(false, "something was invalid when calling slot_is_reachable")
			return false


## Returns true if a list of slots are empty
## Takes a list of slot numbers
## NOTE: Field Independent
func slots_empty(slot_pos: Array) -> bool:
	for no in slot_pos:
		var slot = get_slot(no)
		if slot.stored_card != null:
			return false

	return true


## Returns slot number of card
func get_slot_no(card: Card) -> int:
	return card.current_slot.slot_no


## Returns position of card in array form
func get_slot_array(card: Card) -> Array[int]:
	return index_to_array(get_slot_no(card))


#region STATIC FUNCTIONS
static func index_to_array(index: int) -> Array[int]:
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


## use slot -1 if card isn't in slot
func destroy_card(slot: int, card: Card) -> void:
	print("Card Destroyed!")

	if card.current_slot != null:
		card.remove_from_slot()

	card.placement = Card.Placement.DESTROYED

	destroyed_cards.append(card)
	card.visible = false
	card.global_position = Vector2.ZERO
	if card.current_slot != null:
		card.remove_from_slot()

	player_field.on_card_destroyed.emit(slot, card)
	enemy_field.on_card_destroyed.emit(slot, card)


func __delete_destroyed_cards() -> void:
	for card in destroyed_cards:
		card.queue_free()
	destroyed_cards = []


func load_game_state(state: BoardState) -> void:
	var should_i_be_active = state.first_player_active if MatchManager.first_player else !state.first_player_active
	if (should_i_be_active and MatchManager._opponent_turn):
		RenderOpponentAction.opponent_finished.emit()
	if (!should_i_be_active and !MatchManager._opponent_turn):
		MatchManager._on_player_finished()
	
	assert(should_i_be_active == !MatchManager._opponent_turn)

	for pos in Global.PLAYER_ROWS + Global.ENEMY_ROWS:
		if get_slot(pos).stored_card != null:
			destroy_card(pos, get_slot(pos).stored_card)

	# TODO: maybe make "game" a global
	var player_hand: PlayerHand = get_node("../PlayerHand")
	var enemy_hand: EnemyHand = get_node("../EnemyHand")

	for card in player_hand.cards + enemy_hand.cards:
		destroy_card(-1, card)
	player_hand.cards = []
	enemy_hand.cards = []

	__delete_destroyed_cards()

	var this_player_index := int(!MatchManager.first_player)
	var enemy_player_index := int(MatchManager.first_player)

	__load_single_side(state, this_player_index, Global.PLAYER_ROWS)
	__load_single_side(state, enemy_player_index, Global.ENEMY_ROWS)

	Global.ram_manager.player_max_ram = state.max_ram[this_player_index]
	Global.ram_manager.player_ram = state.ram[this_player_index]

	Global.ram_manager.opponent_max_ram = state.max_ram[enemy_player_index]
	Global.ram_manager.opponent_ram = state.ram[enemy_player_index]

	assert(state.traps == [[null, null], [null, null]], "traps aren't implemented yet")

	for id in state.hands[this_player_index]:
		player_hand.add_card(id)

	for id in state.hands[enemy_player_index]:
		enemy_hand.add_card(id)


func __load_single_side(state: BoardState, side: int, positions: Array[int]) -> void:
	print("Loading side %d" % side)
	for pos in positions:
		var row := index_to_array(pos)[0]
		var column := index_to_array(pos)[1]

		var card_state: CardState = state.cards[side][row][column]

		if card_state == null:
			continue

		# NOTE: get_parent() get_node("game") get_node("Game") (keywords for refactoring)
		var game_card := Card.create_card(Global.player_field.get_parent(), card_state.id)

		game_card.set_seal(card_state.sealed_turns_left)
		game_card.set_shield(card_state.shield)
		game_card.state.health = card_state.health

		assert(game_card.state.equals(card_state))

		game_card.placement = Card.Placement.PLAYMAT  # Update card
		game_card.flip_card()
		game_card.set_slot(get_slot(pos))
		game_card.move_and_reanchor(get_slot(pos).global_position)
		game_card.set_card_visibility()


static func array_to_index(array: Array, side: Field.Side) -> int:
	if side == Side.Player:
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

	assert(false, "impossible case reached in array_to_index in field.gd")
	return 0
#endregion
