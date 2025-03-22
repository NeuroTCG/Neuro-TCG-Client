class_name EnemyHand
extends Hand

@export var game: Game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderOpponentAction.summon.connect(_on_summon)
	RenderOpponentAction.draw_card.connect(_on_draw_card)
	RenderOpponentAction.deck_master_init.connect(_on_deck_master_init)

	# Set hand positions
	for i in range(5):
		get_node("Pos" + str(i + 1)).position.x = 4 * CARD_LENGTH - i * CARD_LENGTH

	Global.enemy_hand = self
	await game.ready


func rearrange_enemy_hand():
	for i in range(0, cards.size()):
		cards[i].move_and_reanchor(card_positions[i].global_position)


func _on_summon(packet: SummonPacket) -> void:
	assert(cards.size() > 0, "Failed to render enemy.  Cards should exist at hand when summoning")

	var slot_no := Field.array_to_index(packet.position.to_array(), Field.Side.Enemy)
	var slot := Global.enemy_field.get_slot(slot_no)
	var hand_pos := get_hand_pos_from_id(packet.new_card.id)
	var summon_card: Card = cards.pop_at(hand_pos)

	# Shift all cards right of summoned card
	rearrange_enemy_hand()

	assert(slot.stored_card == null)

	summon_card.set_slot(slot)
	summon_card.move_and_reanchor(slot.global_position)

	Global.enemy_ram_changed.emit(packet.new_ram)


func _on_draw_card(packet: DrawCardPacket) -> void:
	assert(packet.card_id >= 0, "The server sent an invalid opponent action")
	add_card(packet.card_id)

func _on_deck_master_init(packet: DeckMasterInitPacket) -> void:
	var slot_no := Field.array_to_index(packet.position.to_array(), Field.Side.Enemy)
	var slot := Global.enemy_field.get_slot(slot_no)

	# Create new card
	var deck_master := Card.create_card(game, packet.new_card.id)
	deck_master.global_position = game.get_node("EnemyDeck").global_position
	deck_master.flip_card(true)
	deck_master.set_slot(slot)
	deck_master.move_and_reanchor(slot.global_position)
	deck_master.set_card_visibility()

	deck_master.owned_by_player = false


func get_hand_pos_from_id(id: int) -> int:
	for card in cards:
		if card.state.id == id:
			return cards.find(card)

	assert(
		false,
		"Failed to render enemy. The card with the requested id does not exist in enemy hand."
	)
	return 0


func add_card(id: int) -> void:
	assert(cards.size() < 5, "Hand should only store 5 cards")

	# Create new card
	var new_card := Card.create_card(game, id)
	new_card.global_position = game.get_node("EnemyDeck").global_position
	new_card.flip_card(true)
	cards.append(new_card)
	new_card.move_and_reanchor(card_positions[cards.size() - 1].global_position)

	new_card.owned_by_player = false


func discard_hand_card_by_hand_pos(hand_pos: int) -> void:
	assert(hand_pos >= 0, "Can't discard a card that doesn't exist")

	var card = cards.pop_at(hand_pos)

	#Make sure to unlock card select
	if (Global.selected_card == card):
		Global.selected_card = null

	get_parent().remove_child(card)
	rearrange_enemy_hand()


func discard_hand_card(card: Card) -> void:

	#Make sure to unlock card select
	if (Global.selected_card == card):
		Global.selected_card = null

	var hand_pos = cards.find(card)
	assert(hand_pos != -1, "Can't discard a card that doesn't exist")
	discard_hand_card_by_hand_pos(hand_pos)
