class_name EndTurnPacket
extends Packet

func _init():
	super(PacketType.EndTurn)

func to_dict() -> Dictionary:
	return {
		"type": type,
	}

static func from_dict(_d: Dictionary):
	return EndTurnPacket.new()