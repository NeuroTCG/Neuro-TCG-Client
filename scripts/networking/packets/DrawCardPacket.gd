extends PacketWithResponseId
class_name DrawCardPacket

var card_id: int
var is_you: bool


func _init(response_id_: int, card_id_: int, is_you_: bool) -> void:
	super(PacketType.DrawCard, response_id_)
	card_id = card_id_
	is_you = is_you_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"card_id": card_id,
				"is_you": is_you,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> DrawCardPacket:
	return DrawCardPacket.new(d["response_id"], d["card_id"], d["is_you"])
