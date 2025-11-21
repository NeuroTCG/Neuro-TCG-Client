extends PacketWithResponseId
class_name DeckMasterRequestPacket

var card_id: int


func _init(response_id_: int, _card_id: int):
	super(PacketType.DeckMasterRequest, response_id_)
	card_id = _card_id


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.merge({"card_id": card_id})
	return dict


static func from_dict(d: Dictionary) -> DeckMasterRequestPacket:
	return DeckMasterRequestPacket.new(d["response_id"], d["card_id"])
