extends CardSlots

func _ready() -> void:
	Global.highlight_enemy_cards.connect(_on_highlight_enemy_cards)
	Global.unhighlight_enemy_cards.connect(_on_unhighlight_enemy_cards)
	RenderOpponentAction.attack.connect(_on_attack)
	RenderOpponentAction.switch.connect(_on_switch)
	
	for slot in get_children():
		slot.visible = false 

func show_slots_for_attack(flag: bool, atk_range := CardInfo.AttackRange.STANDARD) -> void:
	if flag:
		for slot in get_children():
			if slot.stored_card:
				if slot.slot_no in [8, 9, 10] and atk_range == CardInfo.AttackRange.STANDARD:
					slot.visible = false 
				else:
					slot.visible = true
			else: 
				slot.visible = false  
	else:
		for slot in get_children(): 
			slot.visible = false 

func _on_switch(packet: SwitchPlacePacket) -> void: 
	var card1_pos = CardSlots.convert_to_index([packet.position1.row, packet.position1.column], true)
	var card2_pos = CardSlots.convert_to_index([packet.position2.row, packet.position2.column], true)
	var card1 = get_node("Slot" + str(card1_pos))
	var card2 = get_node("Slot" + str(card2_pos))
	
	switch_cards(card1, card2) 
	
func _on_attack() -> void:
	# Nothing should actually happen here for now since 
	# attacks are rendered on the player card slots 
	pass  

func _on_highlight_enemy_cards(card: Card, atk_range: CardInfo.AttackRange) -> void:
	show_slots_for_attack(true, atk_range) 

func _on_unhighlight_enemy_cards(card: Card) -> void:
	show_slots_for_attack(false) 
