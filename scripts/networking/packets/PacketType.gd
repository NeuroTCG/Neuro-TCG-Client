class_name PacketType

const ClientInfo: String = "client_info"
const ClientInfoAccept: String = "client_info_accept"
const Disconnect: String = "disconnect"
const Authenticate: String = "authenticate"
const AuthenticationValid: String = "authentication_valid"
const RuleInfo: String = "rule_info"
const MatchFound: String = "match_found"
const UnknownPacket: String = "unknown_packet"
const GetBoardState: String = "get_board_state"
const GetBoardStateResponse: String = "get_board_state_response"

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
	RuleInfo,
	MatchFound,
	UnknownPacket,
	GetBoardState,
	GetBoardStateResponse,

	Summon,
	SummonResponse,
	SummonOpponent,

	Attack,
	AttackResponse,
	AttackOpponent,
]
