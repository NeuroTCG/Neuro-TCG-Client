extends Packet
class_name GetBoardStatePacket

var reason: String


class Reason:
	const state_conflict := "auth_invalid"
	const reconnect := "reconnect"
	const connect := "connect"
	const debug := "debug"

	static var allReasons: Array[String] = [state_conflict, reconnect, connect, debug]


func _init(reason_: String) -> void:
	super(PacketType.GetBoardState)
	reason = reason_


func to_dict() -> Dictionary:
	return {"type": type, "reason": reason}


static func from_dict(d: Dictionary) -> GetBoardStatePacket:
	assert(d["reason"] in Reason.allReasons)
	return GetBoardStatePacket.new(d["reason"])
