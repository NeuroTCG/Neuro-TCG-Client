extends Packet
class_name DrawCardRequestPacket


func _init() -> void:
	super(PacketType.DrawCardRequest)


func to_dict() -> Dictionary:
	return {
		"type": type,
	}


static func from_dict(_d: Dictionary) -> DrawCardRequestPacket:
	return DrawCardRequestPacket.new()
