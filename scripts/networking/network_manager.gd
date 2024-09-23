class_name NetworkManager
extends Node

#region COMMAND SIGNALS
signal get_board_state_response(packet: GetBoardStateResponsePacket)
signal authentication_valid(packet: AuthenticationValidPacket)
signal client_info_accept(packet: ClientInfoAcceptPacket)
signal disconnect(packet: DisconnectPacket)
signal rule_info(packet: RuleInfoPacket)
signal match_found(packet: MatchFoundPacket)
signal unknown_packet(packet: UnknownPacketPacket)
signal switch_place(packet: SwitchPlacePacket)
signal start_turn(packet: StartTurnPacket)
signal end_turn(packet: EndTurnPacket)
signal draw_card(packet: DrawCardPacket)

signal attack(packet: AttackPacket)
#endregion

# Maybe good idea to replace error with an object with more details, idk.
signal invalid_command(error: String)

signal on_packet_received(packet: Packet)

var client := Client.new()

const protocol_version = 1


func _ready() -> void:
	add_child(client)


func start_initial_packet_sequence():
	invalid_command.connect(__on_invalid_command)
	client_info_accept.connect(__on_client_info_answer, CONNECT_ONE_SHOT)
	authentication_valid.connect(__on_authenticate_answer, CONNECT_ONE_SHOT)
	disconnect.connect(__on_disconnect, CONNECT_ONE_SHOT)
	rule_info.connect(__on_rules_packet, CONNECT_ONE_SHOT)
	match_found.connect(__on_match_found, CONNECT_ONE_SHOT)
	await client.wait_until_connection_opened()
	send_packet(ClientInfoPacket.new("Official Client", "0.0.1", protocol_version))


func __on_invalid_command(error: String):
	assert(false, error)


func __on_unknown_packet(packet: UnknownPacketPacket):
	print("Unknown packet with message '%s' was sent to server" % packet.message)
	assert(false, "unknown packets should not exist")


func __on_disconnect(packet: DisconnectPacket):
	print("Client info was invalid: '%s' (%s)" % [packet.message, packet.reason])


func __on_client_info_answer(_packet: ClientInfoAcceptPacket):
	print("Connected to server (protocol v%d)" % protocol_version)
	send_packet(AuthenticatePacket.new("Neuro"))


func __on_authenticate_answer(packet: Packet):
	print("User authenticated")
	if (packet as AuthenticationValidPacket).has_running_game:
		print("Reconnecting to existing game...")
	else:
		print("Waiting for matchmaking")


func __on_rules_packet(packet: Packet):
	print("Rules received")
	print((packet as RuleInfoPacket).card_id_mapping)


func __on_match_found(packet: MatchFoundPacket):
	print("Match found")
	if packet.is_first_player:
		print("We are first")
	else:
		print("We are second")

	client_info_accept.disconnect(__on_client_info_answer)
	authentication_valid.disconnect(__on_authenticate_answer)
	disconnect.disconnect(__on_disconnect)
	rule_info.disconnect(__on_rules_packet)
	match_found.disconnect(__on_match_found)


func send_packet(packet: Packet):
	var data = PacketUtils.serialize(packet)
	client.ws.send_text(data)
	print("'%s' packet was sent" % packet.type)


func receive_command(msg: String):
	var packet = PacketUtils.deserialize(msg)
	print("'%s' packet received by packet logger" % [packet.type])

	on_packet_received.emit(packet)

	match packet.type:
		PacketType.ClientInfoAccept:
			client_info_accept.emit(packet)
		PacketType.Disconnect:
			disconnect.emit(packet)
		PacketType.AuthenticationValid:
			authentication_valid.emit(packet)
		PacketType.RuleInfo:
			rule_info.emit(packet)
		PacketType.MatchFound:
			match_found.emit(packet)
		PacketType.UnknownPacket:
			unknown_packet.emit(packet)
		PacketType.GetBoardStateResponse:
			get_board_state_response.emit(packet)
		PacketType.Summon:
			if packet.is_you:
				if not packet.valid:
					invalid_command.emit("Summon by client failed!")
			else:
				RenderOpponentAction.summon.emit(packet)
		PacketType.Attack:
			attack.emit(packet)
			if packet.is_you:
				if not packet.valid:
					invalid_command.emit("Attack by client failed!")
			else:
				print("Attack Packet is received and IS FROM OPPONENT")
				RenderOpponentAction.attack.emit(packet)

		PacketType.SwitchPlace:
			if packet.is_you:
				if not packet.valid:
					invalid_command.emit("Switch by client failed!")
			else:
				RenderOpponentAction.switch.emit(packet)
		PacketType.UseAbility:
			if packet.is_you:
				if not packet.valid:
					invalid_command.emit("Ability usage by client failed!")
			else:
				RenderOpponentAction.ability.emit(packet)

		PacketType.StartTurn:
			RenderOpponentAction.opponent_finished.emit()

		PacketType.DrawCard:
			print(packet.is_you)
			draw_card.emit(packet)
			if !packet.is_you:
				RenderOpponentAction.draw_card.emit(packet)

		var type:
			assert(false, "Received unhandled packet type '%s'" % type)
