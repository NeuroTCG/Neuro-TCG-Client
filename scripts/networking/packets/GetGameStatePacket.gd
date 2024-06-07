extends Packet
class_name GetGameStatePacket

var response_id: int
var reason: String

class Reason:
	const state_conflict: String = "auth_invalid"
	const reconnect: String = "reconnect"
	const connect: String = "connect"
	const debug: String = "debug"

	static var allReasons = [state_conflict, reconnect, connect, debug]

func _init(reason_: String, response_id_: int=Packet.get_next_response_id()):
	super(PacketType.GetGameState)
	response_id = response_id_
	reason = reason_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"response_id": response_id,
	}

func get_response_id() -> int:
	return response_id
	
static func from_dict(d: Dictionary):
	assert(d["reason"] in Reason.allReasons)
	return GetGameStatePacket.new(d["reason"], d["response_id"])
