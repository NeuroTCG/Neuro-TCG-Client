extends Packet
class_name AuthenticationValidPacket

var has_running_game: bool
var you: UserInfo


func _init(has_running_game_: bool, you_: UserInfo) -> void:
	super(PacketType.AuthenticationValid)
	has_running_game = has_running_game_
	you = you_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"has_running_game": has_running_game,
		"you": you.to_dict(),
	}


static func from_dict(d: Dictionary) -> AuthenticationValidPacket:
	return AuthenticationValidPacket.new(d["has_running_game"], UserInfo.from_dict(d["you"]))
