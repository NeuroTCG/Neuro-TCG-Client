class_name PacketType

const ClientInfo: String = "client_info"
const ClientInfoAccept: String = "client_info_accept"
const Disconnect: String = "disconnect"
const Authenticate: String = "authenticate"
const AuthenticationValid: String = "authentication_valid"
const MatchFound: String = "match_found"
const UnknownPacket: String = "unknown_packet"
const GetGameState: String = "get_game_state"

const Summon: String = "summon"
const SummonResponse: String = "summon_response"
const SummonOpponent: String = "summon_opponent"

const Attack: String = "attack"
const AttackResponse: String = "attack_response"
const AttackOpponent: String = "attack_opponent"

const allTypes: Array[String] = [
	ClientInfo,
	ClientInfoAccept,
	Disconnect,
	Authenticate,
	AuthenticationValid,
	MatchFound,
	UnknownPacket,
	GetGameState,

	Summon,
	SummonResponse,
	SummonOpponent,

	Attack,
	AttackResponse,
	AttackOpponent,
]
