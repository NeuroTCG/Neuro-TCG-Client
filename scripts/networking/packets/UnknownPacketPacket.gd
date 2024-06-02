extends Packet
class_name UnknownPacketPacket

var response_id: int
var type: String = PacketType.UnknownPacket

func _init(response_id_: int):
	response_id = response_id_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"response_id": response_id,
	}

static func from_dict(d: Dictionary):
	return UnknownPacketPacket.new(d["response_id"])
