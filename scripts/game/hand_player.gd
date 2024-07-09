extends Hand

@export var game: Node2D


func _ready() -> void:
	Global.hand_card_selected.connect(_on_card_selected)
	Global.hand_card_unselected.connect(_on_card_unselected)
	Global.slot_chosen.connect(_on_slot_chosen)
	
	# Set hand positions  
	for i in range(5):
		get_node("Pos" + str(i+1)).position.x = i * CARD_LENGTH
	
	await game.ready
	for i in range(5):
		add_card(i) 
		await get_tree().create_timer(0.2).timeout 

func add_card(id: int) -> void:
	assert(cards.size() < 5, "Hand should only store 5 cards")
	
	# Create new card 
	var new_card = Card.create_card(game, id)
	new_card.global_position = game.get_node("Deck").global_position
	new_card.flip_card()
	cards.append(new_card)
	await new_card.move_card(card_positions[cards.size()-1].global_position, true)
	
	# Make Hand command available (Summon) 
	new_card.placement = Card.Placement.HAND 

func summon(hand_pos: int, slot_no: int) -> void:
	assert(cards.size() > 0, "Cards should exist at hand when summoning")
	
	var slot_pos = game.get_node("CardSlots").get_slot_pos(slot_no)
	var summon_card = cards.pop_at(hand_pos)
	
	Global.fill_slot.emit(slot_no, summon_card)  # Update slot 
	selected_card = null  # Update hand  
	summon_card.placement = Card.Placement.PLAYMAT # Update card 
	
	# Shift all cards right of summoned card
	for i in range(hand_pos, cards.size()):
		cards[i].move_card(card_positions[i].global_position, true)
	
	# Move card and reset card visibility 
	await summon_card.move_card(slot_pos, true) 
	summon_card.set_card_visibility()

func _on_card_selected(card: Card) -> void:
	selected_card = card  
	card.shift_card_y(-30)
	card.select()
	card.set_card_visibility(100)
	Global.show_slots.emit(true)

func _on_card_unselected(card: Card) -> void:
	if card == selected_card:
		# If another card has been selected, this section either
		# won't run or will be overwritten by _on_card_selected
		selected_card = null 
		Global.show_slots.emit(false)
	card.shift_card_y(0)
	card.unselect()

func _on_slot_chosen(slot_no: int, _card: Card) -> void:
	if selected_card:
		Global.show_slots.emit(false)
		selected_card.unselect()
		summon(cards.find(selected_card), slot_no)
