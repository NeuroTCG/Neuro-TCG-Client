extends Hand

@export var game: Node2D


func _ready() -> void:
	Global.hand_card_selected.connect(_on_card_selected)
	Global.hand_card_unselected.connect(_on_card_unselected)
	Global.slot_chosen.connect(_on_slot_chosen)
	MatchManager.action_summon.connect(_on_action_summon)
	Global.network_manager.draw_card.connect(_on_draw_card)

	# Set hand positions
	for i in range(5):
		get_node("Pos" + str(i + 1)).position.x = i * CARD_LENGTH

	await game.ready


func _process(_delta):
	if MatchManager.input_paused or MatchManager._opponent_turn:
		return

	if Input.is_action_just_pressed("draw_card") and cards.size() < 5:
		print("Is opponent turn is ", MatchManager._opponent_turn)
		Global.network_manager.send_packet(DrawCardRequestPacket.new())


func _on_draw_card(packet: DrawCardPacket):
	if packet.is_you:
		assert(packet.card_id >= 0, "draw_card was invalid")
		add_card(packet.card_id)


func add_card(id: int) -> void:
	assert(cards.size() < 5, "Hand should only store 5 cards")

	# Create new card
	var new_card = Card.create_card(game, id)
	new_card.global_position = game.get_node("PlayerDeck").global_position
	new_card.flip_card()
	cards.append(new_card)
	await new_card.move_and_reanchor(card_positions[cards.size() - 1].global_position)

	# Make Hand command available (Summon)
	new_card.placement = Card.Placement.HAND


func summon(hand_pos: int, slot_no: int) -> void:
	assert(cards.size() > 0, "Cards should exist at hand when summoning")

	var slot = Global.player_field.get_slot(slot_no)
	var summon_card: Card = cards.pop_at(hand_pos)

	Global.player_field.cards.append(summon_card)

	summon_card.placement = Card.Placement.PLAYMAT  # Update card
	summon_card.summon_sickness = true

	# Shift all cards right of summoned card
	for i in range(hand_pos, cards.size()):
		cards[i].move_and_reanchor(card_positions[i].global_position)

	# Update ram
	Global.use_ram.emit(summon_card.info.cost)

	# Move card and reset card visibility
	summon_card.set_slot(slot)
	await summon_card.move_and_reanchor(slot.global_position)
	summon_card.set_card_visibility()


func _on_card_selected(card: Card) -> void:
	selected_card = card
	card.shift_card_y(-30)
	card.select()
	card.show_buttons([MatchManager.Actions.SUMMON, MatchManager.Actions.VIEW])
	card.set_card_visibility(100)


func _on_card_unselected(card: Card) -> void:
	card.shift_card_y(0)
	Global.hide_player_slots.emit()
	card.hide_buttons()
	card.unselect()

	if not another_card_selected(card):
		selected_card = null


func another_card_selected(card: Card) -> bool:
	for c in cards:
		if c != card and c.mouse_over:
			return true

	return false


func _on_action_summon() -> void:
	Global.show_player_slots_for_summon.emit()


#func _on_action_view() -> void:
#if selected_card:
#Global.view_card.emit(selected_card)


func _on_slot_chosen(slot_no: int, _card: Card) -> void:
	if selected_card:
		var summoned_card: Card = selected_card

		_on_card_unselected(summoned_card)
		VerifyClientAction.summon.emit(summoned_card.state.id, Field.index_to_array(slot_no))
		summon(cards.find(summoned_card), slot_no)
