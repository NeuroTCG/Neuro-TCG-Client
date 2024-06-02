extends Packet
class_name MatchFoundPacket

var opponent: UserInfo
var game_id: String
var is_reconnect: bool
var type: String = PacketType.MatchFound

func _init(opponent_: UserInfo, game_id_: String, is_reconnect_: bool):
	opponent = opponent_
	game_id = game_id_
	is_reconnect = is_reconnect_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"opponent": opponent.to_dict(),
		"game_id": game_id,
		"is_reconnect": is_reconnect,
	}

static func from_dict(d: Dictionary):
	return MatchFoundPacket.new(UserInfo.from_dict(d["opponent"]), d["game_id"], d["is_reconnect"])
