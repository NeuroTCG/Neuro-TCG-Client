extends PacketWithResponseId
class_name SummonRequestPacket

var card: CardData
var position: CardPosition


func _init(response_id_: int, card_: CardData, position_: CardPosition) -> void:
	super(PacketType.SummonRequest, response_id_)
	card = card_
	position = position_


func to_dict() -> Dictionary:
	var dict := super.to_dict()

	(
		dict
		. merge(
			{
				"card": card.to_dict(),
				"position": position.to_array(),
			}
		)
	)

	return dict


static func from_dict(d: Dictionary) -> SummonRequestPacket:
	return SummonRequestPacket.new(
		d["response_id"], CardData.from_dict(d["card"]), CardPosition.from_array(d["position"])
	)
