class_name SwitchPlacePacket
extends Packet

var is_you: bool
var valid: bool
var position1: CardPosition
var position2: CardPosition

func _init(is_you_: bool, valid_: bool, position1_: CardPosition, position2_: CardPosition):
	super(PacketType.SwitchPlace)
	is_you = is_you_
	valid = valid_
	position1 = position1_
	position2 = position2_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"is_you": is_you,
		"valid": valid,
		"position1": position1.to_array(),
		"position2": position2.to_array(),
	}

static func from_dict(d: Dictionary):
	return SwitchPlacePacket.new(
		d["is_you"],
		d["valid"],
		CardPosition.from_array(d["position1"]),
		CardPosition.from_array(d["position2"])
	)