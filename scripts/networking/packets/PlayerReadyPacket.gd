extends Packet
class_name PlayerReadyPacket

func _init() -> void:
	super(PacketType.PlayerReady)


func to_dict() -> Dictionary:
	return {
		"type": type,
	}


static func from_dict(_d: Dictionary) -> PlayerReadyPacket:
	return PlayerReadyPacket.new()
