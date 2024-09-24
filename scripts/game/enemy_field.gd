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
	RenderOpponentAction.ability.connect(_on_ability)

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


func show_slots_for_direct_attack() -> void:
	for slot in get_children():
		if slot.stored_card:
			slot.visible = true
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
	var slot1 := get_node("Slot" + str(card1_pos))
	var slot2 := get_node("Slot" + str(card2_pos))
	var card1: Card = slot1.stored_card
	var card2: Card = slot2.stored_card

	if card1 == null:
		assert(card2 != null)
		# TODO: don't manually move cards
		Global.unfill_slot.emit(card2_pos, card2)
		Global.fill_slot.emit(card1_pos, card2)
		card2.move_card(slot1.global_position)
	elif card2 == null:
		assert(card1 != null)
		# TODO: don't manually move cards
		Global.unfill_slot.emit(card1_pos, card1)
		Global.fill_slot.emit(card2_pos, card1)
		card1.move_card(slot2.global_position)
	else:
		switch_cards(card1, card2)


func _on_attack(packet: AttackPacket) -> void:
	var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
	var target_card: Card = player_field.get_node("Slot" + str(target_slot_no)).stored_card

	if packet.target_card == null:
		destroy_card(target_slot_no, target_card)

		# If hp is the same, target card was not able to counterattack
		# the attacking card.
	else:
		target_card.render_attack(packet.target_card.health)
		# TODO: make this an assert and calculate it correctly
		target_card.state.shield = packet.target_card.shield

		# If hp is the same, target card was not able to counterattack
		# the attacking card.
	var atk_slot_no = Field.convert_to_index(packet.attacker_position.to_array(), true)
	var atk_card: Card = get_node("Slot" + str(atk_slot_no)).stored_card

	if packet.attacker_card == null:
		destroy_card(atk_slot_no, atk_card)

		# If hp is the same, target card was not able to counterattack
		# the attacking card.
	else:
		# TODO: make this an assert and calculate it correctly
		atk_card.statestate..shield = packet.attacker_card.shield
		# If hp is the same, target card was not able to counterattack
		# the attacking card.
		if atk_card.state.health != packet.attacker_card.health:
			atk_card.render_attack(packet.attacker_card.health)


func _on_ability(packet: UseAbilityPacket) -> void:
	# Ability card will always be from the opponent
	var ability_slot_no = Field.convert_to_index(packet.ability_position.to_array(), true)
	var ability_card: Card = enemy_field.get_node("Slot" + str(ability_slot_no)).stored_card

	# TODO: don't manually touch RAM
	var enemy_ram = get_tree().get_first_node_in_group("ram_manager").opponent_ram
	Global.update_enemy_ram.emit(enemy_ram - ability_card.info.ability.cost)

	# TODO: make this a match?
	if ability_card.info.ability.effect == Ability.AbilityEffect.ADD_HP:
		# In this case the target card will always be an opponent card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array(), true)
		var target_card: Card = enemy_field.get_node("Slot" + str(target_slot_no)).stored_card
		# TODO: don't manually touch health and shield
		target_card.state.health = packet.target_card.health
		target_card.state.shield = packet.target_card.shield
	elif (
		ability_card.info.ability.effect == Ability.AbilityEffect.ATTACK
		and ability_card.info.ability.range == Ability.AbilityRange.ENEMY_CARD
	):
		# In this case the target card will always be the player's card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_node("Slot" + str(target_slot_no)).stored_card
		# TODO: don't manually touch health and shield
		target_card.state.health = packet.target_card.health
		target_card.state.shield = packet.target_card.shield
	elif (
		ability_card.info.ability.effect == Ability.AbilityEffect.ATTACK
		and ability_card.info.ability.range == Ability.AbilityRange.ENEMY_ROW
	):
		# In this case the target card will always be the player's card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_node("Slot" + str(target_slot_no)).stored_card

		var atk_value = target_card.info.ability.value
		var row
		if target_slot_no in Global.PLAYER_BACK_ROW:
			row = Global.PLAYER_BACK_ROW
		elif target_slot_no in Global.PLAYER_FRONT_ROW:
			row = Global.PLAYER_FRONT_ROW

			for slot_no in row:
				var slot = player_field.get_node("Slot%d" % slot_no)
				if slot.stored_card:
					slot.stored_card.render_attack_with_atk_value(atk_value)

					if slot.stored_card <= 0:
						# TODO: wtf is this
						player_field.destroy_card(slot_no, slot.stored_card)
	elif ability_card.info.ability.effect == Ability.AbilityEffect.SEAL:
		print("APPLYING SEAL TO CARD")
		# In this case the target card will always be the player's card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_node("Slot" + str(target_slot_no)).stored_card
		target_card.state.sealed_turns_left = ability_card.info.ability.value
		print(target_card.state.sealed_turns_left)
		target_card.seal_sprite.visible = true
	elif ability_card.info.ability.effect == Ability.AbilityEffect.SHIELD:
		print("APPLYING SHIELD TO CARD")
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array(), true)
		var target_card: Card = enemy_field.get_node("Slot" + str(target_slot_no)).stored_card
		target_card.state.shield = ability_card.info.ability.value
		print(target_card.state.shield)


#endregion


func destroy_card(slot: int, card: Card) -> void:
	print("(From Opponent) Card Destroyed!")
	Global.unfill_slot.emit(slot, card)
	destroyed_cards.append(card)
	card.visible = false
	card.global_position = Vector2.ZERO
