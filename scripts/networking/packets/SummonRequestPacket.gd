extends Packet
class_name SummonRequestPacket

var card_id: int
var position: CardPosition


func _init(card_id_: int, position_: CardPosition) -> void:
	super(PacketType.SummonRequest)
	card_id = card_id_
	position = position_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"card_id": card_id,
		"position": position.to_array(),
	}


static func from_dict(d: Dictionary) -> SummonRequestPacket:
	return SummonRequestPacket.new(d["card_id"], CardPosition.from_array(d["position"]))
