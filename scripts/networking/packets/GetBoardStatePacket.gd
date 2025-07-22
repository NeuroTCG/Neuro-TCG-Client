extends PacketWithResponseId
class_name GetBoardStatePacket

var reason: String


class Reason:
	const state_conflict := "auth_invalid"
	const reconnect := "reconnect"
	const connect := "connect"
	const debug := "debug"

	static var allReasons: Array[String] = [state_conflict, reconnect, connect, debug]


func _init(response_id_: int, reason_: String) -> void:
	super(PacketType.GetBoardState, response_id_)
	reason = reason_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.merge({"reason": reason})
	return dict


static func from_dict(d: Dictionary) -> GetBoardStatePacket:
	assert(d["reason"] in Reason.allReasons)
	return GetBoardStatePacket.new(d["response_id"], d["reason"])
