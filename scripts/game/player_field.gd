extends Field
## When moving a card, keep track of card.placement, Slots,
## cards, and selected_card

var cards := []
var destroyed_cards := [] 
var selected_card: Card = null

func _ready() -> void:
	Global.show_player_slots_for_summon.connect(show_slots_for_summon)
	Global.hide_player_slots.connect(hide_slots)
	Global.slot_chosen.connect(_on_slot_chosen)
	Global.enemy_slot_chosen.connect(_on_enemy_slot_chosen)
	Global.playmat_card_selected.connect(_on_card_selected)
	Global.playmat_card_unselected.connect(_on_card_unselected)
	Global.fill_slot.connect(_on_fill_slot)
	Global.unfill_slot.connect(_on_unfill_slot)
	MatchManager.action_switch.connect(_on_action_switch)
	MatchManager.action_attack.connect(_on_action_attack)
	MatchManager.action_ability.connect(_on_action_ability)

	for slot in get_children():
		slot.visible = false

func _on_fill_slot(slot_no: int, card: Card) -> void:
	if card.owned_by_player:
		cards.append(card)

func _on_unfill_slot(slot_no: int, card: Card) -> void:
	if card.owned_by_player:
		cards.erase(card)

#region SHOW SLOT 
func show_slots_for_summon() -> void:
	for slot in get_children():
		if not slot.stored_card:
			slot.visible = true
		else:
			slot.visible = false

func show_slots_for_transfer() -> void:
	for slot in get_children():
		slot.visible = true
		
		# Don't show selected card  
		if slot.stored_card:
			if slot.stored_card == selected_card:
				slot.visible = false

func show_all_ally_cards() -> void:
	for slot in get_children():
		if slot.stored_card:
			slot.visible = true 
		else:
			slot.visible = false 
			
func hide_slots() -> void:
	for slot in get_children():
			slot.visible = false
#endregion 

#region SELECT
func _on_card_selected(card: Card) -> void:
	if MatchManager.current_action == MatchManager.Actions.SWITCH:
		MatchManager.current_action = MatchManager.Actions.IDLE
	else:
		var default_buttons = [MatchManager.Actions.SWITCH, MatchManager.Actions.ATTACK, MatchManager.Actions.VIEW]
		
		if card.card_info.ability.effect != Ability.AbilityEffect.NONE:
			default_buttons.append(MatchManager.Actions.ABILITY)	
		
		if card.summon_sicknes:
			default_buttons.erase(MatchManager.Actions.SWITCH) 	
			default_buttons.erase(MatchManager.Actions.ATTACK)
			default_buttons.erase(MatchManager.Actions.ABILITY)
		if card.moved_or_acted:
			default_buttons.erase(MatchManager.Actions.SWITCH)
		
		card.show_buttons(default_buttons)
		selected_card = card
		card.select()

func _on_card_unselected(card: Card) -> void:
	card.hide_buttons()
	card.unselect()
	Global.hide_enemy_cards.emit()
	
	# If another card has been selected, 
	# Update these values from the _on_card_selected
	# that will run from that card being clicked on 
	if not another_card_selected(card):
		selected_card = null
		hide_slots()
		MatchManager.current_action = MatchManager.Actions.IDLE

func another_card_selected(card: Card) -> bool:
	for c in cards:
		if c != card and c.mouse_over:
			return true
	
	return false

#endregion

#region ON BUTTON PRESSED 
func _on_action_switch() -> void:
	show_slots_for_transfer()

func _on_action_attack() -> void:
	Global.show_enemy_slots_for_attack.emit(selected_card)

func _on_action_ability() -> void:
	show_all_ally_cards()
#endregion

#region ON SLOT CHOSEN 
func _on_slot_chosen(slot_no: int, card: Card) -> void:
	if MatchManager.current_action == MatchManager.Actions.SWITCH: 
		if card:
			card.moved_or_acted = true 
			selected_card.moved_or_acted = true 
		
			card.unselect()
			VerifyClientAction.switch.emit(get_slot_array(card), get_slot_array(selected_card))
			switch_cards(card, selected_card)
			
			# Update card slots 
			selected_card = null
			hide_slots()

		if selected_card:
			selected_card.moved_or_acted = true 
			# Send packet
			VerifyClientAction.switch.emit(get_slot_array(selected_card), convert_to_array(slot_no))

			# Change slots 
			Global.unfill_slot.emit(get_slot_no(selected_card), selected_card)
			Global.fill_slot.emit(slot_no, selected_card)
			
			# Change visuals 
			selected_card.move_card(get_slot_pos(slot_no), true)
			
	if MatchManager.current_action == MatchManager.Actions.ABILITY:
		if selected_card: 
			print("BEFORE: ", selected_card.moved_or_acted)
			selected_card.moved_or_acted = true 
			print("AFTER: ", selected_card.moved_or_acted)
			
			if selected_card.card_info.ability.effect == Ability.AbilityEffect.ADD_HP_TO_ALLY_CARD:
				print("Card ability in effect. HP before: ", card.hp)
				card.hp += selected_card.card_info.ability.value
				print("Hp afterwords: ", card.hp)
				
		hide_slots()

func _on_enemy_slot_chosen(enemy_slot_no: int, enemy_card: Card) -> void:
	var player_card = selected_card
	var player_slot_no = get_slot_no(player_card)
	
	if MatchManager.current_action == MatchManager.Actions.ATTACK:
		player_card.moved_or_acted = true 
		
		enemy_card.render_attack_client(player_card)
		VerifyClientAction.attack.emit(player_card.id, convert_to_array(enemy_slot_no), convert_to_array(player_slot_no))
		
		if enemy_card.hp <= 0: 
			enemy_field.destroy_card(enemy_slot_no, enemy_card)
		
		# Enemy counterattack 
		if not slot_is_reachable(player_slot_no, enemy_card, false):
			return 
		else:
			VerifyClientAction.attack.emit(enemy_card.id, convert_to_array(player_slot_no), convert_to_array(enemy_slot_no), true)
			selected_card.render_attack(max(selected_card.hp - (enemy_card.atk - 1), 0))
			
			if selected_card.hp <= 0:
				destroy_card(player_slot_no, player_card) 
#endregion 

func destroy_card(slot:int, card: Card) -> void:
	print("Card Destroyed!")
	Global.unfill_slot.emit(slot, card)
	cards.erase(card)
	if selected_card == card:
		selected_card = null 
	card.placement = Card.Placement.DESTROYED
	
	destroyed_cards.append(card)
	card.visible = false
	card.global_position = Vector2.ZERO 
