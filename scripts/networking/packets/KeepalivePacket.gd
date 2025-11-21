class_name KeepalivePacket
extends Packet


func _init() -> void:
	super(PacketType.Keepalive)


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge({})
	return dict


static func from_dict(_d: Dictionary) -> KeepalivePacket:
	return KeepalivePacket.new()
