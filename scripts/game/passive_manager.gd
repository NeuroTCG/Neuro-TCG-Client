extends Node

signal update_passive(packet: PassiveUpdatePacket)


func _ready():
	update_passive.connect(_on_passive_update)


func _on_passive_update(packet: PassiveUpdatePacket):
	for u in packet.updates:
		var user: CardData = u.card

		for action in u.actions:
			#TODO: Use a function variable to consolidate this.

			match action.action_name:
				CardActionNames.TEST:
					pass
				CardActionNames.ADD_HP:
					handle_add_hp_action(user, action)
				CardActionNames.ADD_ATTACK:
					handle_add_attack_action(user, action)
				CardActionNames.SUB_HP:
					handle_sub_hp_action(user, action)
				CardActionNames.SUB_ATTACK:
					handle_sub_attack_action(user, action)
				CardActionNames.ATTACK:
					print_not_implemented_string(CardActionNames.ATTACK, user, action.targets)
				CardActionNames.SET_PHASE:
					handle_set_phase(user, action)
				CardActionNames.SET_ABILITY_USED:
					print_not_implemented_string(
						CardActionNames.SET_ABILITY_USED, user, action.targets
					)
				CardActionNames.DRAW_CARD:
					handle_draw_card_action(user, action)
				var name:
					assert(false, "unknown action name was received from packet. %s" % [name])


func get_hand(card_idx: int) -> Hand:
	var my_index = MatchManager.player_index()
	var hand: Hand = null
	if my_index == card_idx:
		hand = Global.player_hand
	else:
		hand = Global.enemy_hand
	return hand


func get_field(card_idx: int) -> Field:
	var my_index = MatchManager.player_index()
	var field: Field = null
	if my_index == card_idx:
		field = Global.player_field
	else:
		field = Global.enemy_field
	return field


func get_side_of_field(field: Field):
	if field is EnemyField:
		return Field.Side.Enemy
	else:
		return Field.Side.Player


func get_card_from_data(card_data: CardData) -> Card:
	var field = get_field(card_data.playerIdx)
	var side = get_side_of_field(field)
	var target_card = (
		field.get_slot(field.array_to_index(card_data.position.to_array(), side)).stored_card
	)
	return target_card


func get_card_from_target(card_target: CardActionTarget) -> Card:
	var field = get_field(card_target.playerIdx)
	var side = get_side_of_field(field)
	var target_slot := field.get_slot(field.array_to_index(card_target.position.to_array(), side))
	assert(
		target_slot.stored_card != null,
		"No card stored at slot %s @ %s! (%s)" % [target_slot, card_target.position, side]
	)

	return target_slot.stored_card


func handle_draw_card_action(user: CardData, action: CardAction):
	var hand: Hand = get_hand(user.playerIdx)
	if hand.cards.size() == 5:
		print("An attempt to draw a card was made thanks to a passive, but the hand was full!")
	else:
		hand.add_card(action.amount)


func handle_add_hp_action(user: CardData, action: CardAction):
	for target: CardActionTarget in action.targets:
		var target_card: Card = get_card_from_target(target)
		target_card.add_hp(action.amount)


func handle_add_attack_action(user: CardData, action: CardAction):
	for target: CardActionTarget in action.targets:
		var target_card: Card = get_card_from_target(target)
		target_card.add_attack(action.amount)


func handle_sub_attack_action(user: CardData, action: CardAction):
	for target: CardActionTarget in action.targets:
		var target_card: Card = get_card_from_target(target)
		target_card.sub_attack(action.amount)
		print("set attack to: %s" % [target_card.current_attack_value])


func handle_add_ability_cost_modifier(user: CardData, action: CardAction):
	for target: CardActionTarget in action.targets:
		var target_card: Card = get_card_from_target(target)
		target_card.add_ability_cost_modifier(action.amount)
		print("set attack to: %s" % [target_card.current_attack_value])


func handle_sub_ability_cost_modifier(user: CardData, action: CardAction):
	for target: CardActionTarget in action.targets:
		var target_card: Card = get_card_from_target(target)
		target_card.sub_ability_cost_modifier(action.amount)
		print("set attack to: %s" % [target_card.current_attack_value])


func handle_set_phase(user: CardData, action: CardAction):
	var target_card: Card = get_card_from_data(user)
	target_card.state.phase = action.amount


func handle_sub_hp_action(user: CardData, action: CardAction):
	var min_hp: int = 0
	assert(
		action.other_args.size() <= 1,
		"Call for Card Action 'SUB HP' had more arguments than expected."
	)

	if action.other_args.has("min_hp"):
		print("setting min_hp to: %s" % [action.other_args["min_hp"]])
		min_hp = int(action.other_args["min_hp"])

	for target: CardActionTarget in action.targets:
		var target_card: Card = get_card_from_target(target)
		var current_hp = target_card.state.health
		target_card.sub_hp(action.amount, min_hp)
		print("set hp to: %s" % [target_card.state.health])


func print_not_implemented_string(
	action_name: String, user: CardData, targets: Array[CardActionTarget]
):
	if user.playerIdx == MatchManager.player_index():
		print("THIS IS THE PLAYER")
	else:
		print("THIS IS THE ENEMY")
	print("%s called a %s action with %d target(s):" % [user, action_name, targets.size()])
	for t in targets:
		print("%s: %s" % [get_card_from_target(t), t])
