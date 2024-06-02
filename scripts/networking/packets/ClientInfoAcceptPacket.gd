extends Packet
class_name ClientInfoAcceptPacket

var type: String = PacketType.ClientInfoAccept

func _init():
	pass

func to_dict() -> Dictionary:
	return {
		"type": type,
	}

static func from_dict(_d: Dictionary):
	return ClientInfoAcceptPacket.new()
