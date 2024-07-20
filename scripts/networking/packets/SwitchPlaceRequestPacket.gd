extends Packet
class_name SwitchPlaceRequestPacket

var position1: CardPosition
var position2: CardPosition

func _init(position1_: CardPosition, position2_: CardPosition):
	super(PacketType.SwitchPlaceRequest)
	position1 = position1_
	position2 = position2_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"position1": position1.to_array(),
		"position2": position2.to_array(),
	}

static func from_dict(d: Dictionary):
	return SwitchPlaceRequestPacket.new(CardPosition.from_array(d["position1"]), CardPosition.from_array(d["position2"]))