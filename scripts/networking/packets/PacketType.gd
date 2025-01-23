class_name PacketType

const ClientInfo := "client_info"
const ClientInfoAccept := "client_info_accept"
const Disconnect := "disconnect"
const Authenticate := "authenticate"
const AuthenticationValid := "authentication_valid"
const RuleInfo := "rule_info"
const MatchFound := "match_found"
const UnknownPacket := "unknown_packet"
const GetBoardState := "get_board_state"
const GetBoardStateResponse := "get_board_state_response"
const GameStart := "game_start"

const DeckMasterInit := "deck_master_init"
const DeckMasterRequest := "deck_master_request"
const DeckMasterSelected := "deck_master_selected"

const Summon := "summon"
const SummonRequest := "summon_request"

const Attack := "attack"
const AttackRequest := "attack_request"

const SwitchPlaceRequest := "switch_place_request"
const SwitchPlace := "switch_place"

const StartTurn := "start_turn"
const EndTurn := "end_turn"

const DrawCardRequest := "draw_card_request"
const DrawCard := "draw_card"

const UseAbilityRequest := "use_ability_request"
const UseAbility := "use_ability"

const UseMagicCardRequest := "use_magic_card_request"
const UseMagicCard := "use_magic_card"

const GameOver: String = "game_over"

const PassiveUpdate: String = "passive_update"

const Keepalive := "keepalive"

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
	UseMagicCardRequest,
	UseMagicCard,
	GameOver,
	PassiveUpdate,
	Keepalive,
	DeckMasterInit,
	DeckMasterRequest,
	DeckMasterSelected,
	GameStart,
]
