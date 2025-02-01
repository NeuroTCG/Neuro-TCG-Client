extends Packet
class_name OpponentReadyPacket

func _init() -> void:
	super(PacketType.OpponentReady)


func to_dict() -> Dictionary:
	return {
		"type": type,
	}


static func from_dict(_d: Dictionary) -> OpponentReadyPacket:
	return OpponentReadyPacket.new()
