extends Packet
class_name DisconnectPacket


# TODO: convert to enum
class Reason:
	const auth_invalid := "auth_invalid"
	const auth_user_banned := "auth_user_banned"
	const protocol_too_old := "protocol_too_old"
	const opponent_disconnect := "opponent_disconnect"
	const game_over := "game_over"
	const double_login := "double_login"

	static var allReasons = [
		auth_invalid,
		auth_user_banned,
		protocol_too_old,
		opponent_disconnect,
		game_over,
		double_login
	]


var message: String
var reason: String


func _init(reason_: String, message_: String) -> void:
	super(PacketType.Disconnect)
	reason = reason_
	message = message_


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	(
		dict
		. merge(
			{
				"message": message,
				"reason": reason,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> DisconnectPacket:
	assert(d["reason"] in Reason.allReasons)
	return DisconnectPacket.new(d["reason"], d["message"])
