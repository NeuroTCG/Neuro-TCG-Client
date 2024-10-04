class_name StartTurnPacket
extends Packet


func _init() -> void:
	super(PacketType.StartTurn)


func to_dict() -> Dictionary:
	return {
		"type": type,
	}


static func from_dict(_d: Dictionary) -> StartTurnPacket:
	return StartTurnPacket.new()
