extends CardSlots

func _ready() -> void:
	Global.highlight_enemy_cards.connect(_on_highlight_enemy_cards)
	Global.unhighlight_enemy_cards.connect(_on_unhighlight_enemy_cards)
	
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

func _on_highlight_enemy_cards(card: Card, atk_range: CardInfo.AttackRange) -> void:
	show_slots_for_attack(true, atk_range) 

func _on_unhighlight_enemy_cards(card: Card) -> void:
	show_slots_for_attack(false) 
