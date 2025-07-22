extends Packet
class_name PlayerReadyPacket


func _init() -> void:
	super(PacketType.PlayerReady)


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge({})
	return dict


static func from_dict(_d: Dictionary) -> PlayerReadyPacket:
	return PlayerReadyPacket.new()
