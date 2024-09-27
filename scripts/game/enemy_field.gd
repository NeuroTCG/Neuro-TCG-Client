extends Field
class_name EnemyField
## Enemy cards only need to worry about Slots and
## Placement when moving them around.

## List to store all destroyed enemy cards


func _ready() -> void:
	Global.show_enemy_slots_for_attack.connect(show_slots_for_attack)
	Global.hide_enemy_cards.connect(hide_slots)
	RenderOpponentAction.attack.connect(_on_attack)
	RenderOpponentAction.switch.connect(_on_switch)
	RenderOpponentAction.ability.connect(_on_ability)

	for slot in get_children():
		slot.visible = false

		# TODO: don't remove this one. This stays for debugging
		var label = Label.new()
		add_child(label)
		label.text = str(slot.slot_no)
		label.global_position = slot.global_position + Vector2(40, 0)
		label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))


#region SHOW SLOTS
func show_slots_for_attack(card: Card) -> void:
	for slot in get_children():
		if not slot is CardSlot:
			continue

		if slot.stored_card:
			if slot_is_reachable(slot.slot_no, card, true):
				slot.visible = true
			else:
				slot.visible = false
		else:
			slot.visible = false


func show_slots_for_direct_attack() -> void:
	for slot in get_children():
		if not slot is CardSlot:
			continue

		if slot.stored_card:
			slot.visible = true
		else:
			slot.visible = false


func hide_slots() -> void:
	for slot in get_children():
		if not slot is CardSlot:
			continue

		slot.visible = false


#endregion


#region RENDER OPPONENT
func _on_switch(packet: SwitchPlacePacket) -> void:
	var slot1 = Field.convert_to_index(packet.position1.to_array(), true)
	var slot2 = Field.convert_to_index(packet.position2.to_array(), true)

	switch_cards(slot1, slot2)


func _on_attack(packet: AttackPacket) -> void:
	var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
	var atk_slot_no = Field.convert_to_index(packet.attacker_position.to_array(), true)

	var target_card: Card = player_field.get_slot(target_slot_no).stored_card
	var atk_card: Card = player_field.get_slot(atk_slot_no).stored_card

	# take_damage deletes the card if it dies so it may not exist after
	var target_atk = target_card.info.base_atk

	target_card.take_damage(atk_card.info.base_atk)
	if target_card.current_slot:  # it did't die
		assert(target_card.state.shield == packet.target_card.shield)

	atk_card.take_damage(max(target_atk - 1, 0))
	if atk_card.current_slot:  # it did't die
		assert(atk_card.state.shield == packet.attacker_card.shield)


func _on_ability(packet: UseAbilityPacket) -> void:
	# Ability card will always be from the opponent
	var ability_slot_no = Field.convert_to_index(packet.ability_position.to_array(), true)
	var ability_card: Card = enemy_field.get_slot(ability_slot_no).stored_card

	Global.use_enemy_ram.emit(ability_card.info.ability.cost)

	# TODO: make this a match?
	if ability_card.info.ability.effect == Ability.AbilityEffect.ADD_HP:
		# In this case the target card will always be an opponent card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array(), true)
		var target_card: Card = enemy_field.get_slot(target_slot_no).stored_card

		target_card.heal(packet.target_card.health - target_card.state.health)

	elif (
		ability_card.info.ability.effect == Ability.AbilityEffect.ATTACK
		and ability_card.info.ability.range == Ability.AbilityRange.ENEMY_CARD
	):
		# In this case the target card will always be the player's card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_slot(target_slot_no).stored_card

		target_card.take_damage(target_card.state.health - packet.target_card.health)
		assert(target_card.state.shield == packet.target_card.shield)

	elif (
		ability_card.info.ability.effect == Ability.AbilityEffect.ATTACK
		and ability_card.info.ability.range == Ability.AbilityRange.ENEMY_ROW
	):
		# In this case the target card will always be the player's card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_slot(target_slot_no).stored_card

		var atk_value = target_card.info.ability.value
		var row
		if target_slot_no in Global.PLAYER_BACK_ROW:
			row = Global.PLAYER_BACK_ROW
		elif target_slot_no in Global.PLAYER_FRONT_ROW:
			row = Global.PLAYER_FRONT_ROW

			for slot_no in row:
				var slot = player_field.get_slot(slot_no)
				if slot.stored_card:
					slot.stored_card.take_damage(atk_value)

	elif ability_card.info.ability.effect == Ability.AbilityEffect.SEAL:
		print("APPLYING SEAL TO CARD")
		# In this case the target card will always be the player's card
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array())
		var target_card: Card = player_field.get_slot(target_slot_no).stored_card
		# TODO: don't manually write to state
		target_card.state.sealed_turns_left = ability_card.info.ability.value
		print(target_card.state.sealed_turns_left)
		target_card.seal_sprite.visible = true
	elif ability_card.info.ability.effect == Ability.AbilityEffect.SHIELD:
		print("APPLYING SHIELD TO CARD")
		var target_slot_no = Field.convert_to_index(packet.target_position.to_array(), true)
		var target_card: Card = enemy_field.get_slot(target_slot_no).stored_card

		target_card.set_shield(ability_card.info.ability.value)
		assert(target_card.state.shield == packet.target_card.shield)
		print(target_card.state.shield)


#endregion


#func destroy_card(slot: int, card: Card) -> void:
	#print("(From Opponent) Card Destroyed!")

	#card.remove_from_slot()

	#destroyed_cards.append(card)
	#card.visible = false
	#card.global_position = Vector2.ZERO
