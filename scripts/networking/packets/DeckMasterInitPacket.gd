extends Packet
class_name DeckMasterInitPacket

var is_you: bool
var valid: bool
var position: CardPosition
var new_card: CardState


func _init(_is_you: bool, _valid: bool, _position: CardPosition, _new_card: CardState):
	super(PacketType.DeckMasterInit)
	is_you = _is_you
	valid = _valid
	position = _position
	new_card = _new_card


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict.merge(
		{
			"is_you": is_you,
			"valid": valid,
			"position": position.to_array(),
			"new_card": new_card.to_dict()
		}
	)
	return dict


static func from_dict(d: Dictionary) -> DeckMasterInitPacket:
	return DeckMasterInitPacket.new(
		d["is_you"],
		d["valid"],
		CardPosition.from_array(d["position"]),
		CardState.from_dict(d["new_card"])
	)
