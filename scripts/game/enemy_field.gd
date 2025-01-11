extends Field
class_name EnemyField

## Enemy cards only need to worry about Slots and
## Placement when moving them around.


func _ready() -> void:
	Global.show_enemy_slots_for_attack.connect(show_slots_for_attack)
	Global.show_enemy_slots_for_magic.connect(show_slots_for_direct_attack)
	Global.hide_enemy_cards.connect(hide_slots)
	RenderOpponentAction.attack.connect(_on_attack)
	RenderOpponentAction.switch.connect(_on_switch)
	RenderOpponentAction.ability.connect(_on_ability)
	RenderOpponentAction.magic.connect(_on_magic)

	for slot in get_children():
		slot.visible = false

		# NOTE: don't remove this one. This stays for debugging
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
			if slot_is_reachable(slot.slot_no, card):
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
	var slot1 := Field.array_to_index(packet.position1.to_array(), Field.Side.Enemy)
	var slot2 := Field.array_to_index(packet.position2.to_array(), Field.Side.Enemy)

	switch_cards(slot1, slot2)


func _on_attack(packet: AttackPacket) -> void:
	var target_slot_no := Field.array_to_index(packet.target_position.to_array(), Field.Side.Player)
	var atk_slot_no := Field.array_to_index(packet.attacker_position.to_array(), Field.Side.Enemy)

	var target_card := player_field.get_slot(target_slot_no).stored_card
	var atk_card := player_field.get_slot(atk_slot_no).stored_card

	# take_damage deletes the card if it dies so it may not exist after
	var target_atk := target_card.current_attack_value

	target_card.take_damage(atk_card.current_attack_value, atk_card)
	if target_card.current_slot:  # it did't die
		assert(target_card.state.shield == packet.target_card.shield)

	atk_card.take_damage(max(target_atk - 1, 0), target_card)
	if atk_card.current_slot:  # it did't die
		assert(atk_card.state.shield == packet.attacker_card.shield)


func _apply_ability(
	ability_card: Card,
	ability: Ability,
	target_position: CardPosition,
	target_card_state: CardState
) -> void:
	Global.use_enemy_ram.emit(ability.cost)

	Global.use_enemy_ram.emit(ability_card.info.ability.cost)

	var targets: Array[Card] = []

	match ability_card.info.ability.range:
		Ability.AbilityRange.ENEMY_ROW:
			var target_slot_no := Field.array_to_index(
				target_position.to_array(), Field.Side.Player
			)
			var target_card := player_field.get_slot(target_slot_no).stored_card

			var atk_value := target_card.info.ability.value
			var row: Array[int]
			if target_slot_no in Global.PLAYER_BACK_ROW:
				row = Global.PLAYER_BACK_ROW
			elif target_slot_no in Global.PLAYER_FRONT_ROW:
				row = Global.PLAYER_FRONT_ROW

				for slot_no in row:
					var slot = player_field.get_slot(slot_no)
					if slot.stored_card:
						targets.append(slot.stored_card)
		Ability.AbilityRange.ENEMY_CARD:
			var target_slot_no := Field.array_to_index(
				target_position.to_array(), Field.Side.Player
			)
			targets.append(player_field.get_slot(target_slot_no).stored_card)
		_:  #Sheild and Heal abilities target allies.
			var target_slot_no := Field.array_to_index(target_position.to_array(), Field.Side.Enemy)
			var target_card = player_field.get_slot(target_slot_no).stored_card
			targets.append(target_card)

	ability_card.apply_ability_to(targets)


func _on_ability(packet: UseAbilityPacket) -> void:
	# Ability card will always be from the opponent
	var ability_slot_no := Field.array_to_index(
		packet.ability_position.to_array(), Field.Side.Enemy
	)
	var ability_card := enemy_field.get_slot(ability_slot_no).stored_card
	_apply_ability(
		ability_card, ability_card.info.ability, packet.target_position, packet.target_card
	)


func _on_magic(packet: UseMagicCardPacket) -> void:
	var magic_user: Card = enemy_field.get_slot(packet.hand_pos).stored_card
	_apply_ability(magic_user, packet.ability, packet.target_position, packet.target_card)
	Global.enemy_hand.discard_hand_card_by_hand_pos(packet.hand_pos)

#endregion
