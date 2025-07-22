extends Packet
class_name DeckMasterSelectedPacket

var valid: bool
var is_you: bool


func _init(valid_: int, is_you_: bool) -> void:
	super(PacketType.DeckMasterSelected)
	valid = valid_
	is_you = is_you_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"valid": valid,
		"is_you": is_you,
	}


static func from_dict(d: Dictionary) -> DeckMasterSelectedPacket:
	return DeckMasterSelectedPacket.new(d["valid"], d["is_you"])
