extends PacketWithResponseId
class_name SwitchPlaceRequestPacket

var position1: CardPosition
var position2: CardPosition


func _init(response_id_: int, position1_: CardPosition, position2_: CardPosition) -> void:
	super(PacketType.SwitchPlaceRequest, response_id_)
	position1 = position1_
	position2 = position2_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"position1": position1.to_array(),
				"position2": position2.to_array(),
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> SwitchPlaceRequestPacket:
	return SwitchPlaceRequestPacket.new(
		d["response_id"],
		CardPosition.from_array(d["position1"]),
		CardPosition.from_array(d["position2"])
	)
