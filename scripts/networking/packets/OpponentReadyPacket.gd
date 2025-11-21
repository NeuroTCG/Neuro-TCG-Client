extends Packet
class_name OpponentReadyPacket


func _init() -> void:
	super(PacketType.OpponentReady)


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge({})
	return dict


static func from_dict(_d: Dictionary) -> OpponentReadyPacket:
	return OpponentReadyPacket.new()
