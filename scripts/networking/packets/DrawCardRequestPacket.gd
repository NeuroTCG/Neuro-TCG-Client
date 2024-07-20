extends Packet
class_name DrawCardRequestPacket

func _init():
	super(PacketType.DrawCardRequest)

func to_dict() -> Dictionary:
	return {
		"type": type,
	}

static func from_dict(_d: Dictionary):
	return DrawCardRequestPacket.new()
