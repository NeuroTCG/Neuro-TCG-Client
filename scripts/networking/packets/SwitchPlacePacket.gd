class_name SwitchPlacePacket
extends PacketWithResponseId

var is_you: bool
var valid: bool
var position1: CardPosition
var position2: CardPosition


func _init(
	response_id_: int,
	is_you_: bool,
	valid_: bool,
	position1_: CardPosition,
	position2_: CardPosition
) -> void:
	super(PacketType.SwitchPlace, response_id_)
	is_you = is_you_
	valid = valid_
	position1 = position1_
	position2 = position2_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"is_you": is_you,
				"valid": valid,
				"position1": position1.to_array(),
				"position2": position2.to_array(),
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> SwitchPlacePacket:
	return SwitchPlacePacket.new(
		d["response_id"],
		d["is_you"],
		d["valid"],
		CardPosition.from_array(d["position1"]),
		CardPosition.from_array(d["position2"])
	)
