class_name StartTurnPacket
extends Packet


func _init() -> void:
	super(PacketType.StartTurn)


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge({})
	return dict


static func from_dict(_d: Dictionary) -> StartTurnPacket:
	return StartTurnPacket.new()
