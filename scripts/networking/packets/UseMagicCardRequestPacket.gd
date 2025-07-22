class_name UseMagicCardRequestPacket
extends PacketWithResponseId

var card_id: int
var target_position: CardPosition
var hand_pos: int


func _init(
	response_id_: int, card_id_: int, target_position_: CardPosition, hand_pos_: int
) -> void:
	super(PacketType.UseMagicCardRequest, response_id_)
	card_id = card_id_
	target_position = target_position_
	hand_pos = hand_pos_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"card_id": card_id,
				"target_position": target_position.to_array(),
				"hand_pos": hand_pos,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> UseMagicCardRequestPacket:
	return (
		UseMagicCardRequestPacket
		. new(
			d["response_id"],
			d["card_id"],
			CardPosition.from_array(d["target_position"]),
			d["hand_pos"],
		)
	)
