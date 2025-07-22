extends PacketWithResponseId
class_name SummonRequestPacket

var card_id: int
var position: CardPosition


func _init(response_id_: int, card_id_: int, position_: CardPosition) -> void:
	super(PacketType.SummonRequest, response_id_)
	card_id = card_id_
	position = position_


func to_dict() -> Dictionary:
	var dict := super.to_dict()

	(
		dict
		. merge(
			{
				"card_id": card_id,
				"position": position.to_array(),
			}
		)
	)

	return dict


static func from_dict(d: Dictionary) -> SummonRequestPacket:
	return SummonRequestPacket.new(
		d["response_id"], d["card_id"], CardPosition.from_array(d["position"])
	)
