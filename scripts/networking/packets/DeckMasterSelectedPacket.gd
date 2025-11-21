extends PacketWithResponseId
class_name DeckMasterSelectedPacket

var valid: bool
var is_you: bool


func _init(response_id_: int, valid_: int, is_you_: bool) -> void:
	super(PacketType.DeckMasterSelected, response_id_)
	valid = valid_
	is_you = is_you_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"valid": valid,
				"is_you": is_you,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> DeckMasterSelectedPacket:
	return DeckMasterSelectedPacket.new(d["response_id"], d["valid"], d["is_you"])
