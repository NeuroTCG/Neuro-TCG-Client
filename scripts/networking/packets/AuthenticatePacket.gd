extends Packet
class_name AuthenticatePacket

var token: String


func _init(token_: String) -> void:
	super(PacketType.Authenticate)
	token = token_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"token": token,
	}


static func from_dict(d: Dictionary) -> AuthenticatePacket:
	return AuthenticatePacket.new(d["token"])
