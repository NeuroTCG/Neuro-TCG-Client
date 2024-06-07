extends Packet
class_name AuthenticatePacket

var username: String

func _init(username_: String):
	super(PacketType.Authenticate)
	username = username_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"username": username,
	}

static func from_dict(d: Dictionary):
	return AuthenticatePacket.new(d["username"])
