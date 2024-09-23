extends Packet
class_name ClientInfoPacket

var client_name: String
var client_version: String
var protocol_version: int


func _init(client_name_: String, client_version_: String, protocol_version_: int):
	super(PacketType.ClientInfo)
	assert(len(client_name_) <= 25)
	assert(len(client_version_) <= 40)
	client_name = client_name_
	client_version = client_version_
	protocol_version = protocol_version_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"client_name": client_name,
		"client_version": client_version,
		"protocol_version": protocol_version,
	}


static func from_dict(d: Dictionary):
	return ClientInfoPacket.new(d["client_name"], d["client_version"], d["protocol_version"])
