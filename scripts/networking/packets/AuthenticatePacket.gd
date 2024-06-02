extends Packet
class_name AuthenticatePacket

var username: String
var type: String = PacketType.Authenticate

func _init(username_: String):
	username = username_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"username": username,
	}

static func from_dict(d: Dictionary):
	return AuthenticatePacket.new(d["username"])
