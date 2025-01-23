extends Packet
class_name GameStartPacket

func _init() -> void:
	super(PacketType.GameStart)


func to_dict() -> Dictionary:
	return {
		"type": type,
	}


static func from_dict(_d: Dictionary) -> GameStartPacket:
	return GameStartPacket.new()
