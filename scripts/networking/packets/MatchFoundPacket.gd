extends Packet
class_name MatchFoundPacket

var opponent: UserInfo
var game_id: int
var is_reconnect: bool
var is_first_player: bool

func _init(opponent_: UserInfo, game_id_: int, is_reconnect_: bool, is_first_player_: bool):
	super(PacketType.MatchFound)
	opponent = opponent_
	game_id = game_id_
	is_reconnect = is_reconnect_
	is_first_player = is_first_player_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"opponent": opponent.to_dict(),
		"game_id": game_id,
		"is_reconnect": is_reconnect,
		"is_first_player": is_first_player,
	}

static func from_dict(d: Dictionary):
	return MatchFoundPacket.new(UserInfo.from_dict(d["opponent"]), d["game_id"], d["is_reconnect"], d["is_first_player"])
