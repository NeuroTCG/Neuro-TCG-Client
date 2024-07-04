extends Node2D
class_name CardSlots 

var cards := [] 
var selected_card = null
var card_transfer_underway := false 

func _ready() -> void:
	Global.show_slots.connect(show_slots)
	Global.slot_chosen.connect(_on_slot_chosen)
	Global.playmat_card_selected.connect(_on_card_selected)
	Global.playmat_card_unselected.connect(_on_card_unselected)
	Global.fill_slot.connect(_on_fill_slot)
	Global.unfill_slot.connect(_on_unfill_slot)
	
	for slot in get_children():
		slot.visible = false 

func _on_fill_slot(slot_no: int, card: Card) -> void:
	cards.append(card)

func _on_unfill_slot(card: Card) -> void:
	cards.erase(card)

func get_slot_pos(slot_no: int) -> Vector2: 
	var pos = get_node("Slot" + str(slot_no)).global_position 
	return pos

## Returns slot number of card 
## Returns 0 if card isn't in any slot 
func get_slot_no(card: Card) -> int:
	for slot in get_children(): 
		if slot.stored_card == card:
			return slot.slot_no
	return 0  

func show_slots(flag: bool) -> void:
	if flag:
		for slot in get_children():
			if not slot.stored_card:
				slot.visible = true
			else: 
				slot.visible = false  
	else:
		for slot in get_children(): 
			slot.visible = false 

func show_slots_for_transfer(flag: bool) -> void:
	if flag: 
		for slot in get_children():
			slot.visible = true 
			
			# Don't show selected card  
			if slot.stored_card:
				if slot.stored_card == selected_card:
					slot.visible = false 

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
	
func _on_card_selected(card: Card) -> void:
	if card_transfer_underway:
		card_transfer_underway = false 
		card.unselect() 
		selected_card.unselect() 
		show_slots(false)
		switch_cards(card, selected_card)
		selected_card = null  
	else:
		card_transfer_underway = true 
		selected_card = card
		card.select() 
		show_slots_for_transfer(true)

func _on_card_unselected(card: Card) -> void:
	# If another card in hand has been selected 
	for c in cards:
		if c != card and c.mouse_over: 
			card.unselect()
			return  
	
	# If the current card or no card has been selected 
	selected_card = null
	show_slots(false)
	card_transfer_underway = false 
	card.unselect()

func _on_slot_chosen(slot_no: int, card: Card) -> void:	
	if card:
		return 
	
	if selected_card:
		# Change slots 
		Global.unfill_slot.emit(get_slot_no(selected_card))
		Global.fill_slot.emit(slot_no, selected_card)
		
		# Change visuals 
		selected_card.move_card(get_slot_pos(slot_no), true) 
		
		card_transfer_underway = false 
		Global.show_slots.emit(false)
		selected_card.unselect()
		selected_card = null 
