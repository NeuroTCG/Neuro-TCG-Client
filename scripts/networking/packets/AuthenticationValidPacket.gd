extends Packet
class_name AuthenticationValidPacket

var has_running_game: bool
var type: String = PacketType.AuthenticationValid

func _init(has_running_game_: bool):
	has_running_game = has_running_game_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"has_running_game": has_running_game,
	}

static func from_dict(d: Dictionary):
	return AuthenticationValidPacket.new(d["has_running_game"])
