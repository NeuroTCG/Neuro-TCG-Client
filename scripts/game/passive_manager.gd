extends Node

signal update_passive(packet: PassiveUpdatePacket)


func _ready():
	update_passive.connect(_on_passive_update)


func _on_passive_update(packet: PassiveUpdatePacket):
	for u in packet.updates:
		var user: CardData = u.card

		for action in u.actions:
			match action.action_name:
				CardActionNames.TEST:
					print_not_implemented_string(CardActionNames.TEST, user, action.targets)
				CardActionNames.ADD_HP:
					print_not_implemented_string(CardActionNames.ADD_HP, user, action.targets)
				CardActionNames.ATTACK:
					print_not_implemented_string(CardActionNames.ATTACK, user, action.targets)
				CardActionNames.SET_ABILITY_USED:
					print_not_implemented_string(
						CardActionNames.SET_ABILITY_USED, user, action.targets
					)
				CardActionNames.DRAW_CARD:
					handle_draw_card_action(user, action)
				var name:
					assert(false, "unknown action name was received from packet. %s" % [name])


func handle_draw_card_action(user: CardData, action: CardAction):
	#Check if whether player or opponent is calling this action.
	var my_index = MatchManager.player_index()

	var hand: Hand = null

	if my_index == user.playerIdx:
		hand = Global.player_hand
	else:
		hand = Global.enemy_hand

	if hand.cards.size() == 5:
		print("An attempt to draw a card was made thanks to a passive, but the hand was full!")
	else:
		hand.add_card(action.amount)


func print_not_implemented_string(
	action_name: String, user: CardData, targets: Array[CardActionTarget]
):
	print("%s called a %s action with %d target(s):" % [user, action_name, targets.size()])
	for t in targets:
		print(t)
