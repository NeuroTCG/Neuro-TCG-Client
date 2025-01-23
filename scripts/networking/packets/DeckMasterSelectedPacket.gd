extends Packet
class_name DeckMasterSelectedPacket

var card_id: int
var is_you: bool


func _init(card_id_: int, is_you_: bool) -> void:
	super(PacketType.DeckMasterSelected)
	card_id = card_id_
	is_you = is_you_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"card_id": card_id,
		"is_you": is_you,
	}


static func from_dict(d: Dictionary) -> DeckMasterSelectedPacket:
	return DeckMasterSelectedPacket.new(d["card_id"], d["is_you"])
