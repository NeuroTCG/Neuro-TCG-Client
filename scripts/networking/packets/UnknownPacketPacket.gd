extends Packet
class_name UnknownPacketPacket

var response_id #: int|null

func _init(response_id_):
	super(PacketType.UnknownPacket)
	response_id = response_id_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"response_id": response_id,
	}

# has no get_response_id because it is not supposed to have a response

static func from_dict(d: Dictionary):
	return UnknownPacketPacket.new(d["response_id"])
