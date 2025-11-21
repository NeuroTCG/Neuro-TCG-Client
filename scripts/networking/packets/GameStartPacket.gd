extends Packet
class_name GameStartPacket


func _init() -> void:
	super(PacketType.GameStart)


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge({})
	return dict


static func from_dict(_d: Dictionary) -> GameStartPacket:
	return GameStartPacket.new()
