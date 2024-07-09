extends CardSlots

@export var player_card_slot: Node2D

func _ready() -> void:
	Global.highlight_enemy_cards.connect(_on_highlight_enemy_cards)
	Global.unhighlight_enemy_cards.connect(_on_unhighlight_enemy_cards)
	
	for slot in get_children():
		slot.visible = false 

func show_slots_for_attack(flag: bool) -> void:
	if flag:
		for slot in get_children():
			if slot.stored_card:
				slot.visible = true
			else: 
				slot.visible = false  
	else:
		for slot in get_children(): 
			slot.visible = false 

func _on_highlight_enemy_cards(card: Card) -> void:
	show_slots_for_attack(true) 

func _on_unhighlight_enemy_cards(card: Card) -> void:
	show_slots_for_attack(false) 
