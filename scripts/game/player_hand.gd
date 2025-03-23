class_name PlayerHand
extends Hand

@export var game: Game


func _ready() -> void:
	Global.hand_card_selected.connect(_on_card_selected)
	Global.hand_card_unselected.connect(_on_card_unselected)
	Global.slot_chosen.connect(_on_slot_chosen)
	MatchManager.action_summon.connect(_on_action_summon)
	MatchManager.action_magic.connect(_on_action_magic)
	Global.network_manager.draw_card.connect(_on_draw_card)
	Global.network_manager.deck_master_init.connect(_on_deck_master_init)
	Global.player_hand = self

	# Set hand positions
	for i in range(5):
		get_node("Pos" + str(i + 1)).position.x = i * CARD_LENGTH

	await game.ready


func _process(_delta) -> void:
	if MatchManager.input_paused or MatchManager._opponent_turn:
		return

	if Input.is_action_just_pressed("draw_card") and cards.size() < 5:
		print("Is opponent turn is ", MatchManager._opponent_turn)
		Global.network_manager.send_packet(DrawCardRequestPacket.new())


func _on_draw_card(packet: DrawCardPacket) -> void:
	if packet.is_you:
		assert(packet.card_id >= 0, "draw_card was invalid")
		add_card(packet.card_id)


func add_card(id: int) -> void:
	assert(cards.size() < 5, "Hand should only store 5 cards")

	# Create new card
	var new_card := Card.create_card(game, id)
	new_card.global_position = game.get_node("PlayerDeck").global_position
	new_card.flip_card()
	cards.append(new_card)
	new_card.move_and_reanchor(card_positions[cards.size() - 1].global_position)

	#Move the card up to the front of the game tree
	game.move_child(new_card, -1)

	# Make Hand command available (Summon)
	new_card.placement = Card.Placement.HAND


func rearrange_player_hand():
	for i in range(0, cards.size()):
		cards[i].move_and_reanchor(card_positions[i].global_position)

func _on_deck_master_init(packet: DeckMasterInitPacket):

	var slot_no := Field.array_to_index(packet.position.to_array(), Field.Side.Player)
	var slot := Global.player_field.get_slot(slot_no)

	# Create new card
	var deck_master := Card.create_card(game, packet.new_card.id)
	deck_master.global_position = game.get_node("PlayerDeck").global_position
	deck_master.flip_card()
	deck_master.set_slot(slot)
	deck_master.move_and_reanchor(slot.global_position)
	deck_master.set_card_visibility()

	Global.player_field.cards.append(deck_master)

	deck_master.placement = Card.Placement.PLAYMAT  # Update card

func summon(hand_pos: int, slot_no: int) -> void:
	assert(cards.size() > 0, "Cards should exist at hand when summoning")

	var slot := Global.player_field.get_slot(slot_no)
	var summon_card: Card = cards.pop_at(hand_pos) as Card

	Global.player_field.cards.append(summon_card)

	summon_card.placement = Card.Placement.PLAYMAT  # Update card

	if summon_card.info.tactics.has(CardStats.Tactic.NIMBLE):
		summon_card.summon_sickness = false
	else:
		summon_card.summon_sickness = true

	# Shift all cards right of summoned card
	rearrange_player_hand()

	# Update ram
	Global.use_ram.emit(summon_card.info.cost)

	# Move card and reset card visibility
	summon_card.set_slot(slot)
	summon_card.move_and_reanchor(slot.global_position)
	summon_card.set_card_visibility()


## Magic that is casted immediately from the hand.
## e.g. board wipes, copy & paste
## ranges that is handled includes enemy field, player field, both fields, hands as target
func _hand_magic() -> void:
	# TODO: to implement in the future
	discard_hand_card(Global.selected_card)
	Global.selected_card = null
	Global.card_select_locked = false


func _on_card_selected(card: Card) -> void:

	#Here to keep the player from selecting another card mid action.
	if (Global.card_select_locked):
		return

	print("hand select")

	Global.card_select_locked = true
	Global.selected_card = card

	card.shift_card_y(-30)
	card.select()
	if card.info.card_type == CardStats.CardType.MAGIC:
		card.show_buttons([MatchManager.Actions.MAGIC, MatchManager.Actions.VIEW])
	else:
		card.show_buttons([MatchManager.Actions.SUMMON, MatchManager.Actions.VIEW])
	card.set_card_visibility(100)


func _on_card_unselected(card: Card) -> void:
	card.shift_card_y(0)
	Global.hide_player_slots.emit()
	card.hide_buttons()
	card.unselect()

	if not another_card_selected(card):
		Global.selected_card = null
	Global.card_select_locked = false


func another_card_selected(card: Card) -> bool:
	for c in cards:
		if c != card and c.mouse_over:
			return true

	return false


func _on_action_summon() -> void:
	Global.show_player_slots_for_summon.emit()


func _on_action_magic() -> void:
	assert(Global.selected_card.info.card_type == CardStats.CardType.MAGIC, "card should be of type magic")

	match Global.selected_card.info.ability.range:
		Ability.AbilityRange.ENEMY_CARD, Ability.AbilityRange.ENEMY_ROW:
			Global.show_enemy_slots_for_magic.emit()
		Ability.AbilityRange.ALLY_CARD:
			Global.show_player_slots_for_magic.emit()
		_:
			VerifyClientAction.magic.emit(
				Global.selected_card.state.id, null, Global.player_hand.get_card_pos(selected_card)
			)
			_hand_magic()


func _on_slot_chosen(slot_no: int, _card: Card) -> void:
	if Global.selected_card:
		var summoned_card: Card = Global.selected_card

		_on_card_unselected(summoned_card)
		VerifyClientAction.summon.emit(summoned_card.state.id, Field.index_to_array(slot_no))
		summon(cards.find(summoned_card), slot_no)


func discard_hand_card(card: Card) -> void:
	var hand_pos = cards.find(card)
	assert(hand_pos != -1, "Can't discard a card that doesn't exist")
	cards.remove_at(hand_pos)

	if (Global.selected_card == card):
		Global.selected_card = null
		Global.card_select_locked = false

	get_parent().remove_child(card)
	rearrange_player_hand()
