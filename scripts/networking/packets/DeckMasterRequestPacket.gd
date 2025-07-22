extends Packet
class_name DeckMasterRequestPacket

var card_id: int


func _init(_card_id: int):
	super(PacketType.DeckMasterRequest)
	card_id = _card_id

func to_dict() -> Dictionary:
	return {
		"type": type,
		"card_id" : card_id
	}

static func from_dict(d: Dictionary) -> DeckMasterRequestPacket:
	return DeckMasterRequestPacket.new(d["card_id"])
