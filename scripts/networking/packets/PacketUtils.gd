class_name PacketUtils

static var _type_to_class: Dictionary = {
	PacketType.ClientInfo: ClientInfoPacket,
	PacketType.ClientInfoAccept: ClientInfoAcceptPacket,
	PacketType.Disconnect: DisconnectPacket,
	PacketType.Authenticate: AuthenticatePacket,
	PacketType.AuthenticationValid: AuthenticationValidPacket,
	PacketType.RuleInfo: RuleInfoPacket,
	PacketType.MatchFound: MatchFoundPacket,
	PacketType.UnknownPacket: UnknownPacketPacket,

	PacketType.GetBoardState: GetBoardStatePacket,
	PacketType.GetBoardStateResponse: GetBoardStateResponsePacket,

	PacketType.Summon: SummonPacket,
	PacketType.SummonRequest: SummonRequestPacket,

	PacketType.Attack: AttackPacket,
	PacketType.AttackRequest: AttackRequestPacket,

	PacketType.SwitchPlace: SwitchPlacePacket,
	PacketType.SwitchPlaceRequest: SwitchPlaceRequestPacket,

	PacketType.StartTurn: StartTurnPacket,
	PacketType.EndTurn: EndTurnPacket,

	PacketType.DrawCard: DrawCardPacket,
	PacketType.DrawCardRequest: DrawCardRequestPacket,
}

static func deserialize(s: String) -> Packet:
	var d = JSON.parse_string(s)
	assert(d.has("type"))
	assert(_type_to_class.has(d["type"]), "Add %s to PacketUtils._type_to_class" % d["type"])

	return _type_to_class[d["type"]].from_dict(d)

static func serialize(packet: Packet) -> String:
	var d_packet = packet.to_dict()
	assert(d_packet.has("type"))
	assert(d_packet["type"] in PacketType.allTypes)
	return JSON.stringify(d_packet)
