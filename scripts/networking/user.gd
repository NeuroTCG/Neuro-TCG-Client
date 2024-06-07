extends Node

signal on_packet_received(packet: Packet)
signal on_game_start

var client: Client

const protocol_version = 1

func start_initial_packet_sequence():
	on_game_start.connect(__print_game_start_text)
	on_packet_received.connect(__on_client_info_answer, Object.CONNECT_ONE_SHOT)
	on_packet_received.connect(__on_match_found)

	send_packet(ClientInfoPacket.new("Official Client", "0.0.1", protocol_version))

func __print_game_start_text():
	print("Game is starting")

func __on_client_info_answer(packet: Packet):
	match packet.type:
		PacketType.ClientInfoAccept:
			print("Connected to server (protocol v%d)" % protocol_version)
			on_packet_received.connect(__on_authenticate_answer, Object.CONNECT_ONE_SHOT)
			send_packet(AuthenticatePacket.new("Neuro"))
		PacketType.Disconnect:
			var dpacket = packet as DisconnectPacket
			print("Client info was invalid: '%s' (%s)" % [dpacket.message, dpacket.reason])
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
		PacketType.Disconnect:
			var dpacket = packet as DisconnectPacket
			print("User authentication failed: '%s' (%s)" % [dpacket.message, dpacket.reason])
		var type:
			print("Received unexpected packet type '%s' from server" % type)
	
func __on_match_found(packet: Packet):
	match packet.type:
		PacketType.MatchFound:
			print("Match found")
			on_game_start.emit()
		var type:
			print("[on_match_found] Received packet type '%s'. Ignoring. " % type)

func send_packet_with_response_callback(packet: Packet, on_response: Callable):
	var response_id = packet.get_response_id()
	var callback = func(recv_packet: Packet, f_self: Callable):
		print("'%s' packet with rid %d was seen by response handler for rid %d" % [recv_packet.type, recv_packet.get_response_id(), response_id])
		if recv_packet.get_response_id() == response_id:
			print("'%s' packet with rid %d was handled by response handler for rid %d" % [recv_packet.type, recv_packet.get_response_id(), response_id])
			on_response.call(recv_packet)
			on_packet_received.disconnect(f_self)
	
	callback = callback.bind(callback)

	on_packet_received.connect(callback)
	send_packet(packet)
	print("'%s' packet with rid %d was sent" % [packet.type, response_id])

func send_packet(packet: Packet):
	var data = PacketUtils.serialize(packet)
	print("'%s' packet with rid %d was sent" % [packet.type, packet.get_response_id()])
	client.ws.send_text(data)

func receive_command(msg: String):
	var packet = PacketUtils.deserialize(msg)
	print("'%s' packet with rid %d received by packet logger" % [packet.type, packet.get_response_id()])

	on_packet_received.emit(packet)
