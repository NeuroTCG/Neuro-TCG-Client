extends Field
class_name PlayerField
## When moving a card, keep track of card.placement, Slots,
## cards, and selected_card

var cards: Array[Card] = []

var selected_slot: CardSlot = null


func _ready() -> void:
	Global.show_player_slots_for_summon.connect(show_slots_for_summon)
	Global.show_player_slots_for_magic.connect(show_all_ally_cards)
	Global.hide_player_slots.connect(hide_slots)
	Global.slot_chosen.connect(_on_slot_chosen)
	Global.enemy_slot_chosen.connect(_on_enemy_slot_chosen)
	Global.playmat_card_selected.connect(_on_card_selected)
	Global.playmat_card_unselected.connect(_on_card_unselected)

	MatchManager.action_switch.connect(_on_action_switch)
	MatchManager.action_attack.connect(_on_action_attack)
	MatchManager.action_ability.connect(_on_action_ability)

	on_card_destroyed.connect(__on_destroy_card)

	for slot in get_children():
		slot.visible = false

		# NOTE: don't remove this one. This stays for debugging
		var label := Label.new()
		add_child(label)
		label.text = str(slot.slot_no)
		label.global_position = slot.global_position + Vector2(40, 0)
		label.set("theme_override_colors/font_color", Color(0, 0, 0, 1))


#region SHOW SLOT
func show_slots_for_summon() -> void:
	for slot in get_children():
		if not slot is CardSlot:
			continue

		if not slot.stored_card:
			slot.visible = true
		else:
			slot.visible = false


func show_slots_for_transfer() -> void:
	for slot in get_children():
		if not slot is CardSlot:
			continue

		slot.visible = true

		# Don't show selected card
		if slot.stored_card:
			if slot.stored_card == selected_slot.stored_card:
				slot.visible = false


func show_all_ally_cards() -> void:
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


#region SELECT
func _on_card_selected(card: Card) -> void:
	print("field select")

	if MatchManager.current_action == MatchManager.Actions.SWITCH:
		MatchManager.current_action = MatchManager.Actions.IDLE
	else:
		if Global.card_select_locked:
			return

		var buttons := [
			MatchManager.Actions.SWITCH, MatchManager.Actions.ATTACK, MatchManager.Actions.VIEW
		]

		if (
			card.info.ability.effect != Ability.AbilityEffect.NONE
			and not card.state.ability_was_used
		):
			buttons.append(MatchManager.Actions.ABILITY)

		if (
			card.summon_sickness
			or card.state.sealed_turns_left > 0
			or card.state.phase == Card.TurnPhase.Done
		):
			buttons = [MatchManager.Actions.VIEW]
		elif card.state.phase == Card.TurnPhase.Action:
			buttons.erase(MatchManager.Actions.SWITCH)
		elif card.state.phase == Card.TurnPhase.AttackOnly:
			buttons.erase(MatchManager.Actions.SWITCH)
			buttons.erase(MatchManager.Actions.ABILITY)
		elif card.state.phase == Card.TurnPhase.MoveOrAbility:
			buttons.erase(MatchManager.Actions.ATTACK)
		elif card.state.phase == Card.TurnPhase.AbilityOnly:
			buttons.erase(MatchManager.Actions.SWITCH)
			buttons.erase(MatchManager.Actions.ATTACK)

		Global.card_select_locked = true
		Global.selected_card = card
		Global.selected_card_from_hand = false
		card.show_buttons(buttons)
		selected_slot = card.current_slot
		selected_slot.stored_card = card
		card.select()


func _on_card_unselected(card: Card) -> void:
	card.hide_buttons()
	card.unselect()
	Global.hide_all_slots()

	# If another card has been selected,
	# Update these values from the _on_card_selected
	# that will run from that card being clicked on
	if not another_card_selected(card):
		MatchManager.current_action = MatchManager.Actions.IDLE

	Global.card_select_locked = false


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
	Global.show_enemy_slots_for_attack.emit(selected_slot.stored_card)


# TODO: either rename this if it only checks for ram or merge it with other stuff
func _on_action_ability() -> void:
	var player_ram := Global.ram_manager.player_ram
	if selected_slot.stored_card.current_ability_cost > player_ram:
		Global.notice.emit("Insufficent Ram to use this ability!")
		return

	if selected_slot.stored_card.info.ability.range == Ability.AbilityRange.ALLY_CARD:
		show_all_ally_cards()
	elif (
		selected_slot.stored_card.info.ability.range == Ability.AbilityRange.ENEMY_CARD
		or selected_slot.stored_card.info.ability.range == Ability.AbilityRange.ENEMY_ROW
	):
		enemy_field.show_slots_for_direct_attack()
	elif selected_slot.stored_card.info.ability.range == Ability.AbilityRange.PLAYER_DECK:
		if selected_slot.stored_card.info.ability.effect == Ability.AbilityEffect.DRAW_CARD:
			#Draw card doesn't need to worry about selecting slots, so just handle the ability right here.
			handle_draw_card_ability()


#endregion


func handle_draw_card_ability() -> void:
	#Check if the player can draw
	print("%d, %d" % [Global.player_hand.cards.size(), Hand.MAX_HAND_SIZE])
	if Global.player_hand.cards.size() >= Hand.MAX_HAND_SIZE:
		Global.notice.emit("Can't draw! Your hand is full!")
		return

	#var selected_card = selected_slot.stored_card
	var selected_card = Global.selected_card

	var card_as_array := get_slot_array(selected_card)
	selected_card.state.phase = Card.TurnPhase.Done
	selected_card.state.ability_was_used = true
	selected_card.apply_ability_to([])

	assert(await VerifyClientAction.ability(card_as_array, card_as_array))


#region ON SLOT CHOSEN
## Slot chosen functions are always run
## before _on_card_selected/unselected functions
func _verify_ability_or_magic(
	action: MatchManager.Actions, source: Card, target_slot: Array[int]
) -> void:
	match action:
		MatchManager.Actions.ABILITY:
			assert(await VerifyClientAction.ability(get_slot_array(source), target_slot))

		MatchManager.Actions.MAGIC:
			assert(
				await VerifyClientAction.magic(
					source,
					null if target_slot == null else CardPosition.from_array(target_slot),
					Global.player_hand.get_card_pos(source)
				)
			)
			Global.player_hand.discard_hand_card(source)


func _on_slot_chosen(slot_no: int, card_in_slot: Card) -> void:
	hide_slots()

	var ability_card: Card = null

	if MatchManager.current_action == MatchManager.Actions.SWITCH:
		assert(selected_slot.stored_card, "No card selected.")

		ability_card = selected_slot.stored_card

		ability_card.state.phase = Card.TurnPhase.Action

		if card_in_slot:
			card_in_slot.state.phase = Card.TurnPhase.Action
			card_in_slot.unselect()

		assert(
			await VerifyClientAction.switch(index_to_array(slot_no), get_slot_array(ability_card))
		)

		var selected_slot_no = get_slot_no(ability_card)

		switch_cards(slot_no, selected_slot_no)

	if (
		MatchManager.current_action == MatchManager.Actions.ABILITY
		|| MatchManager.current_action == MatchManager.Actions.MAGIC
	):
		assert(selected_slot.stored_card, "No card selected.")

		ability_card = selected_slot.stored_card

		#Some abilities can destroy other cards.
		#Ignore ability if the card is trying to destroy itself.
		if (
			ability_card == card_in_slot
			and ability_card.info.ability.effect == Ability.AbilityEffect.BUFF_SELF_REMOVE_CARD
		):
			return

		ability_card.state.phase = Card.TurnPhase.Done

		# TODO: don't manually write to state
		ability_card.state.ability_was_used = true

		ability_card = selected_slot.stored_card
		var ability_targets: Array[Card]

		match ability_card.info.ability.range:
			Ability.AbilityRange.ALLY_CARD:
				ability_targets.append(card_in_slot)
			Ability.AbilityRange.ALLY_FIELD:
				for n in Global.PLAYER_ROWS:
					var slot = player_field.get_slot(n)
					if slot.stored_card:
						ability_targets[slot.stored_card] = slot.stored_card

		#Save the position of the card before using the ability, as it may get destroyed.

		var target_card_pos_array := get_slot_array(card_in_slot)

		ability_card.apply_ability_to(ability_targets)

		assert(
			await VerifyClientAction.ability(target_card_pos_array, get_slot_array(ability_card))
		)


func _on_enemy_slot_chosen(enemy_slot_no: int, enemy_card: Card) -> void:
	var player_card := Global.selected_card

	Global.hide_enemy_cards.emit()
	player_card.state.phase = Card.TurnPhase.Done
	enemy_card.dont_show_view = true

	if MatchManager.current_action == MatchManager.Actions.ATTACK:
		var player_slot_no := get_slot_no(player_card)

		var response := await VerifyClientAction.attack(
			player_card.state.id, index_to_array(enemy_slot_no), index_to_array(player_slot_no)
		)
		assert(response.valid)

		assert(
			(
				player_slot_no
				== array_to_index(response.attacker_position.to_array(), Field.Side.Player)
			)
		)
		assert(
			enemy_slot_no == array_to_index(response.target_position.to_array(), Field.Side.Enemy)
		)
		assert(enemy_slot_no == get_slot_no(enemy_card))

		var can_counterattack := slot_is_reachable(player_slot_no, enemy_card)

		# take_damage destroys the card if it dies so we have to read the value here
		var counter_attack_value = enemy_card.current_counter_attack_value

		var target_died = enemy_card.take_damage(player_card.current_attack_value, player_card)

		var player_died = false
		if can_counterattack:
			player_died = player_card.take_damage(counter_attack_value, enemy_card)

		assert(target_died == (response.target_card == null))
		assert(player_died == (response.attacker_card == null))

		if not player_died:
			assert(player_card.state.health == (response.attacker_card.health))
		if not target_died:
			assert(enemy_card.state.health == (response.target_card.health))

		#endregion

	elif (
		MatchManager.current_action == MatchManager.Actions.ABILITY
		|| MatchManager.current_action == MatchManager.Actions.MAGIC
	):
		var ability_targets: Array[Card] = []

		match player_card.info.ability.range:
			Ability.AbilityRange.ENEMY_CARD:
				ability_targets.append(enemy_card)
			Ability.AbilityRange.ENEMY_ROW:
				var row: Array[int]

				if enemy_slot_no in Global.ENEMY_BACK_ROW:
					row = Global.ENEMY_BACK_ROW
				elif enemy_slot_no in Global.ENEMY_FRONT_ROW:
					row = Global.ENEMY_FRONT_ROW

				for slot_no in row:
					var slot = enemy_field.get_slot(slot_no)
					if slot.stored_card:
						ability_targets.append(slot.stored_card)

		player_card.apply_ability_to(ability_targets)

		_verify_ability_or_magic(
			MatchManager.current_action, player_card, index_to_array(enemy_slot_no)
		)


#endregion


func __on_destroy_card(_slot: int, card: Card) -> void:
	cards.erase(card)
	if selected_slot != null and selected_slot.stored_card == card:
		selected_slot.stored_card = null
