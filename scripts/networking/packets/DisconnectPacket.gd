extends Packet
class_name DisconnectPacket

class Reason:
	const auth_invalid: String = "auth_invalid"
	const auth_user_banned: String = "auth_user_banned"
	const protocol_too_old: String = "protocol_too_old"

	static var allReasons = [auth_invalid, auth_user_banned, protocol_too_old]

var message: String
var reason: String
var type: String = PacketType.Disconnect

func _init(reason_: String, message_: String):
	reason = reason_
	message = message_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"message": message,
		"reason": reason,
	}

static func from_dict(d: Dictionary):
	assert(d["reason"] in Reason.allReasons)
	return DisconnectPacket.new(d["reason"], d["message"])
