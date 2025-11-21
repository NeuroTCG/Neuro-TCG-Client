class_name EndTurnPacket
extends Packet


func _init() -> void:
	super(PacketType.EndTurn)


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge({})
	return dict


static func from_dict(_d: Dictionary) -> void:
	return EndTurnPacket.new()
