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
signal use_ability(packet: UseAbilityPacket)
signal deck_master_init(packet: DeckMasterInitPacket)
signal start_turn(packet: StartTurnPacket)
signal draw_card(packet: DrawCardPacket)
signal game_over(packet: GameOverPacket)
signal game_start(packet: GameStartPacket)
signal deck_master_selected(packet: DeckMasterSelectedPacket)
signal passive_update(packet: PassiveUpdatePacket)
signal opponent_ready(packet: OpponentReadyPacket)
signal player_ready(packet: PlayerReadyPacket)
signal summon(packet: SummonPacket)
signal magic(packet: UseMagicCardPacket)

signal attack(packet: AttackPacket)
#endregion

# Maybe good idea to replace error with an object with more details, idk.
signal invalid_command(error: String)

signal on_packet_received(packet: Packet)

var connection: Connection

const PROTOCOL_VERSION := 1

var is_first_player := true


func _ready() -> void:
	connection = Connection.new()
	add_child(connection)


func start_initial_packet_sequence() -> void:
	invalid_command.connect(__on_invalid_command)
	disconnect.connect(__on_disconnect, CONNECT_ONE_SHOT)
	rule_info.connect(__on_rules_packet, CONNECT_ONE_SHOT)
	match_found.connect(__on_match_found, CONNECT_ONE_SHOT)

	await connection.wait_until_connection_opened()

	var _client_info_response: ClientInfoAcceptPacket = await send_packet_and_await_response(
		ClientInfoPacket.new(
			Packet.next_response_id(), "Official Client", "0.0.1", PROTOCOL_VERSION
		),
		false,  # the loading screen needs this
	)
	print("Connected to server (client protocol v%d)" % PROTOCOL_VERSION)
	var auth_response: AuthenticationValidPacket = await send_packet_and_await_response(
		AuthenticatePacket.new(Packet.next_response_id(), Auth.token),
		false,  # the loading screen needs this
	)
	print("User authenticated")
	if auth_response.has_running_game:
		print("Reconnecting to existing game...")
	else:
		print("Waiting for matchmaking")

	send_keepalive_forever()


func send_keepalive_forever() -> void:
	send_packet(KeepalivePacket.new())
	get_tree().create_timer(20).timeout.connect(send_keepalive_forever)


func __on_invalid_command(error: String) -> void:
	assert(false, error)


func __on_unknown_packet(packet: UnknownPacketPacket) -> void:
	print("Unknown packet with message '%s' was sent to server" % packet.message)
	assert(false, "unknown packets should not exist")


func __on_disconnect(packet: DisconnectPacket) -> void:
	print("Disconnect packet: '%s' (%s)" % [packet.message, packet.reason])


func __on_game_start(packet: Packet) -> void:
	print("Game is starting...")
	game_start.emit(packet)


func __on_rules_packet(packet: Packet) -> void:
	print("Rules received")
	print((packet as RuleInfoPacket).card_id_mapping)


func __on_match_found(packet: MatchFoundPacket) -> void:
	print("Match found")
	if packet.is_first_player:
		print("We are first")
		is_first_player = true
	else:
		print("We are second")
		is_first_player = false


func send_packet(packet: Packet) -> void:
	var data := PacketUtils.serialize(packet)
	connection.ws.send_text(data)
	print("'%s' packet was sent" % packet.type)


var pending_responses: Dictionary[int, Array] = {}


## set `consuming` to false to also send the package to its signal
func send_packet_and_await_response(
	packet: PacketWithResponseId, consuming = true
) -> PacketWithResponseId:
	var data := PacketUtils.serialize(packet)
	connection.ws.send_text(data)
	print("'%s' packet was sent" % packet.type)

	var response_id = packet.response_id

	assert(!pending_responses.has(response_id), "The response id %d was used twice" % response_id)
	pending_responses[response_id] = [Future.new(), consuming]

	var response_packet = await pending_responses[response_id][0].wait()

	return response_packet


func receive_command(msg: String) -> void:
	var packet := PacketUtils.deserialize(msg)
	print("'%s' packet received by packet logger" % [packet.type])

	on_packet_received.emit(packet)

	if packet is PacketWithResponseId && packet.response_id != -1:
		assert(
			pending_responses.has(packet.response_id),
			"A packet with response_id was received but no handler was registered."
		)
		pending_responses[packet.response_id][0].resolve(packet)
		var consuming = pending_responses[packet.response_id][1]
		pending_responses.erase(packet.response_id)
		if consuming:
			return

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
		PacketType.OpponentReady:
			opponent_ready.emit(packet)
		PacketType.PlayerReady:
			player_ready.emit(packet)
		PacketType.DeckMasterInit:
			if packet.is_you:
				assert(packet.valid, "deck_master_init failed.")
				deck_master_init.emit(packet)
			else:
				RenderOpponentAction.deck_master_init.emit(packet)
		PacketType.DeckMasterSelected:
			deck_master_selected.emit(packet)
		PacketType.Summon:
			assert(
				!packet.is_you,
				"SummonPacket wasn't handled. Most likely caused by not using send_packet_and_await_response when sending the SummonRequestPacket"
			)
			summon.emit(packet)
			RenderOpponentAction.summon.emit(packet)
		PacketType.Attack:
			assert(
				!packet.is_you,
				"AttackPacket wasn't handled. Most likely caused by not using send_packet_and_await_response when sending the AttackRequestPacket"
			)
			print("Attack Packet is received and IS FROM OPPONENT")
			attack.emit(packet)
			RenderOpponentAction.attack.emit(packet)
		PacketType.SwitchPlace:
			assert(
				!packet.is_you,
				"SwitchPlacePacket wasn't handled. Most likely caused by not using send_packet_and_await_response when sending the SwitchPlaceRequestPacket"
			)
			switch_place.emit(packet)
			RenderOpponentAction.switch.emit(packet)
		PacketType.UseAbility:
			assert(
				!packet.is_you,
				"UseAbilityPacket wasn't handled. Most likely caused by not using send_packet_and_await_response when sending the UseAbilityRequestPacket"
			)
			use_ability.emit(packet)
			RenderOpponentAction.ability.emit(packet)

		PacketType.UseMagicCard:
			assert(
				!packet.is_you,
				"UseMagicCardPacket wasn't handled. Most likely caused by not using send_packet_and_await_response when sending the UseMagicCardRequestPacket"
			)
			magic.emit(packet)
			RenderOpponentAction.magic.emit(packet)

		PacketType.StartTurn:
			start_turn.emit(packet)
			RenderOpponentAction.opponent_finished.emit()

		PacketType.DrawCard:
			print(packet.is_you)
			assert(
				!(packet.is_you && packet.response_id != -1),
				"DrawCardPacket wasn't handled. Most likely caused by not using send_packet_and_await_response when sending the DrawCardRequestPacket"
			)
			draw_card.emit(packet)
			if !packet.is_you:
				RenderOpponentAction.draw_card.emit(packet)

		PacketType.GameOver:
			print("game is over!")
			game_over.emit(packet)

		PacketType.PassiveUpdate:
			passive_update.emit(packet)
			PassiveManager.update_passive.emit(packet)
		PacketType.GameStart:
			game_start.emit(packet)

		var type:
			assert(false, "Received unhandled packet type '%s'" % type)
