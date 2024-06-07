extends Packet
class_name ClientInfoAcceptPacket

func _init():
	super(PacketType.ClientInfoAccept)

func to_dict() -> Dictionary:
	return {
		"type": type,
	}

static func from_dict(_d: Dictionary):
	return ClientInfoAcceptPacket.new()
