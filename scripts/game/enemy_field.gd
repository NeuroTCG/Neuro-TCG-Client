extends Field
## Enemy cards only need to worry about Slots and 
## Placement when moving them around. 

## List to store all destroyed enemy cards 
var destroyed_cards := [] 

func _ready() -> void:
	Global.show_enemy_slots_for_attack.connect(show_slots_for_attack)
	Global.hide_enemy_cards.connect(hide_slots)
	RenderOpponentAction.attack.connect(_on_attack)
	RenderOpponentAction.switch.connect(_on_switch)
	
	for slot in get_children():
		slot.visible = false

#region SHOW SLOTS 
func show_slots_for_attack(card: Card) -> void:
	for slot in get_children():
		if slot.stored_card:
			if slot_is_reachable(slot.slot_no, card, true):
				slot.visible = true
			else:
				slot.visible = false
		else:
			slot.visible = false

func hide_slots() -> void:
	for slot in get_children():
		slot.visible = false 
#endregion
	
#region RENDER OPPONENT 
func _on_switch(packet: SwitchPlacePacket) -> void:
	var card1_pos = Field.convert_to_index(packet.position1.to_array(), true)
	var card2_pos = Field.convert_to_index(packet.position2.to_array(), true)
	var slot1 := get_node("Slot"+ str(card1_pos))
	var slot2 := get_node("Slot"+ str(card2_pos))
	var card1: Card = slot1.stored_card
	var card2: Card = slot2.stored_card
	
	if card1 == null:
		assert(card2 != null)
		Global.unfill_slot.emit(card2_pos, card2)
		Global.fill_slot.emit(card1_pos, card2)
		card2.move_card(slot1.global_position)
	elif card2 == null:
		assert(card1 != null)
		Global.unfill_slot.emit(card1_pos, card1)
		Global.fill_slot.emit(card2_pos, card1)
		card1.move_card(slot2.global_position)
	else:
		switch_cards(card1, card2)

func _on_attack(packet: AttackPacket) -> void:
	# If the other player is being counterattacked whilst attacking 
	#TODO: Remove this first block when reach is implemented server-side 
	if packet.counterattack:
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array(), true)
		var target_card: Card = self.get_node("Slot"+ str(target_slot_no)).stored_card
		
		if packet.target_card == null: 
			destroy_card(target_slot_no, target_card)
		else:
			target_card.render_attack(packet.target_card.health)
	# If the other player is attacking 
	else:
		#TODO: Keep this section when reach is implemented server-side 
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_node("Slot"+ str(target_slot_no)).stored_card
	
		if packet.target_card == null: 
			destroy_card(target_slot_no, target_card)
		else:
			target_card.render_attack(packet.target_card.health)
			
		#TODO: Uncomment this section when reach is implemented server-side 
		#var atk_slot_no = Field.convert_to_index(packet.attacker_position.to_array(), true)
		#var atk_card: Card = get_node("Slot"+ str(atk_slot_no)).stored_card
		#
		#if packet.attacker_card == null:
			#destroy_card(atk_slot_no, atk_card)
		#else:
			## If hp is the same, target card was not able to counterattack 
			## the attacking card.
			#if atk_card.hp != packet.attacker_card.health:
				#atk_card.render_attack(packet.attacker_card.health)
			
#endregion 

func destroy_card(slot:int, card: Card) -> void:
	print("(From Opponent) Card Destroyed!")
	Global.unfill_slot.emit(slot, card) 
	destroyed_cards.append(card)
	card.visible = false 
	card.global_position = Vector2.ZERO 
