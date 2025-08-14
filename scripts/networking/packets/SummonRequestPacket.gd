extends PacketWithResponseId
class_name SummonRequestPacket

var card_state: CardState
var position: CardPosition


func _init(response_id_: int, card_state_: CardState, position_: CardPosition) -> void:
	super(PacketType.SummonRequest, response_id_)
	card_state = card_state_
	position = position_


func to_dict() -> Dictionary:
	var dict := super.to_dict()

	(
		dict
		. merge(
			{
				"card_state": card_state.to_dict(),
				"position": position.to_array(),
			}
		)
	)

	return dict


static func from_dict(d: Dictionary) -> SummonRequestPacket:
	return SummonRequestPacket.new(
		d["response_id"], CardState.from_dict(["card_state"]), CardPosition.from_array(d["position"])
	)
