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
const SummonRequest: String = "summon_request"

const Attack: String = "attack"
const AttackRequest: String = "attack_request"

const SwitchPlaceRequest: String = "switch_place_request"
const SwitchPlace: String = "switch_place"

const StartTurn: String = "start_turn"
const EndTurn: String = "end_turn"

const DrawCardRequest: String = "draw_card_request"
const DrawCard: String = "draw_card"

const UseAbilityRequest: String = "use_ability_request"
const UseAbility: String = "use_ability"

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
	SummonRequest,

	Attack,
	AttackRequest,
	
	SwitchPlace,
	SwitchPlaceRequest,

	StartTurn,
	EndTurn,

	DrawCardRequest,
	DrawCard,
	
	UseAbilityRequest,
	UseAbility,
]
