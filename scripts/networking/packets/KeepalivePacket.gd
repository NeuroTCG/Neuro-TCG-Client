class_name KeepalivePacket
extends Packet


func _init() -> void:
	super(PacketType.Keepalive)


func to_dict() -> Dictionary:
	return {
		"type": type,
	}


static func from_dict(_d: Dictionary) -> KeepalivePacket:
	return KeepalivePacket.new()
