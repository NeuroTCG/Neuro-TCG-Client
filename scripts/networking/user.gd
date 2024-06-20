extends Node

var was_packet_handled: bool = false
signal on_packet_received(packet: Packet)
signal on_game_start

var client: Client

const protocol_version = 1

func start_initial_packet_sequence():
	on_game_start.connect(__print_game_start_text)
	on_packet_received.connect(__on_client_info_answer, CONNECT_ONE_SHOT)
	on_packet_received.connect(__on_match_found)

	send_packet(ClientInfoPacket.new("Official Client", "0.0.1", protocol_version))

func __print_game_start_text():
	print("Game is starting")

func __on_client_info_answer(packet: Packet):
	match packet.type:
		PacketType.ClientInfoAccept:
			print("Connected to server (protocol v%d)" % protocol_version)
			on_packet_received.connect(__on_authenticate_answer, CONNECT_ONE_SHOT)
			send_packet(AuthenticatePacket.new("Neuro"))
			was_packet_handled = true
		PacketType.Disconnect:
			var dpacket = packet as DisconnectPacket
			print("Client info was invalid: '%s' (%s)" % [dpacket.message, dpacket.reason])
			was_packet_handled = true
		var type:
			print("Received unexpected packet type '%s' from server" % type)

func __on_authenticate_answer(packet: Packet):
	match packet.type:
		PacketType.AuthenticationValid:
			print("User authenticated")
			if ((packet as AuthenticationValidPacket).has_running_game):
				print("Reconnecting to existing game...")
			else:
				print("Waiting for matchmaking")
			
			on_packet_received.connect(__on_rules_packet, CONNECT_ONE_SHOT)
			was_packet_handled = true

		PacketType.Disconnect:
			var dpacket = packet as DisconnectPacket
			print("User authentication failed: '%s' (%s)" % [dpacket.message, dpacket.reason])
			was_packet_handled = true
		var type:
			print("Received unexpected packet type '%s' from server" % type)

func __on_rules_packet(packet: Packet):
	match packet.type:
		PacketType.RuleInfo:
			# TODO: store them somewhere
			print("Rules received")
			print((packet as RuleInfoPacket).card_id_mapping)
			was_packet_handled = true
		var type:
			print("Received unexpected packet type '%s' from server" % type)

func __on_match_found(packet: Packet):
	match packet.type:
		PacketType.MatchFound:
			print("Match found")
			on_game_start.emit()
			on_packet_received.disconnect(__on_match_found)
			was_packet_handled = true
		var type:
			print("[on_match_found] Received packet type '%s'. Ignoring. " % type)

## The callback `on_response` must take a `Packet` as its only argument and return true if the
## packet was handled by this callback. It should return false otherwise
func send_packet_with_response_callback(packet: Packet, on_response: Callable):
	var response_id = packet.get_response_id()
	var callback = func(recv_packet: Packet, f_self: Callable):
		print("'%s' packet with rid %d was seen by response handler for rid %d" % [recv_packet.type, recv_packet.get_response_id(), response_id])
		if recv_packet.get_response_id() == response_id:
			print("'%s' packet with rid %d was handled by response handler for rid %d" % [recv_packet.type, recv_packet.get_response_id(), response_id])
			was_packet_handled = on_response.call(recv_packet) or was_packet_handled
			on_packet_received.disconnect(f_self)
	
	callback = callback.bind(callback)

	on_packet_received.connect(callback)
	send_packet(packet)
	print("'%s' packet with rid %d was sent" % [packet.type, response_id])

## The callback `on_response` must take a `Packet` as its only argument and return true if the
## packet was handled by this callback. It should return false otherwise
func send_packet_expecting_type(packet: Packet, expected_response_type: String, on_response: Callable):
	send_packet_with_response_callback(packet, func(response: Packet) -> bool:
		match response.type:
			expected_response_type:
				return on_response.call(response)
				
			var type:
				print("Unexpected packet type '%s'. (was expecting %s)" % [type, expected_response_type])
				return false
	)

func send_packet(packet: Packet):
	var data = PacketUtils.serialize(packet)
	client.ws.send_text(data)
	print("'%s' packet with rid %d was sent" % [packet.type, packet.get_response_id()])

func receive_command(msg: String):
	var packet = PacketUtils.deserialize(msg)
	print("'%s' packet with rid %d received by packet logger" % [packet.type, packet.get_response_id()])

	was_packet_handled = false
	on_packet_received.emit(packet)
	
	# can change this to a print if it gets annoying
	assert(was_packet_handled, "A '%s' packet with rid %d wasn't handled" % [packet.type, packet.get_response_id()])
