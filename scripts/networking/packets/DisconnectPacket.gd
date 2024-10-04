extends Packet
class_name DisconnectPacket


class Reason:
	const auth_invalid := "auth_invalid"
	const auth_user_banned := "auth_user_banned"
	const protocol_too_old := "protocol_too_old"
	const opponent_disconnect := "opponent_disconnect"

	static var allReasons: Array[String] = [
		auth_invalid, auth_user_banned, protocol_too_old, opponent_disconnect
	]


var message: String
var reason: String


func _init(reason_: String, message_: String) -> void:
	super(PacketType.Disconnect)
	reason = reason_
	message = message_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"message": message,
		"reason": reason,
	}


static func from_dict(d: Dictionary) -> DisconnectPacket:
	assert(d["reason"] in Reason.allReasons)
	return DisconnectPacket.new(d["reason"], d["message"])
