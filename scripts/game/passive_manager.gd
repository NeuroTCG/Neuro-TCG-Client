extends Node

signal update_passive(packet: PassiveUpdatePacket)

func _init():
	update_passive.connect(_on_passive_update)

func _on_passive_update(packet: PassiveUpdatePacket):

	print("attempting to parse %d updates..." % [packet.updates.size()])

	for u in packet.updates:

		var user : CardData = u.card;

		for action in u.actions:
			match action.action_name:

				CardActionNames.TEST:
					print("%s called a test action with %d target(s):" % [user, action.targets.size()])
					for t in action.targets:
						print(t)

				var name:
					assert(false, "unknown action name was received from packet. %s" % [name])
