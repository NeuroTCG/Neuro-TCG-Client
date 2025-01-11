class_name UseMagicCardRequestPacket
extends Packet

var card_id: int
var target_position: CardPosition
var hand_pos: int


func _init(card_id_: int, target_position_: CardPosition, hand_pos_: int) -> void:
	super(PacketType.UseMagicCardRequest)
	card_id = card_id_
	target_position = target_position_
	hand_pos = hand_pos_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"card_id": card_id,
		"target_position": target_position.to_array(),
		"hand_pos": hand_pos,
	}


static func from_dict(d: Dictionary) -> UseMagicCardRequestPacket:
	return (
		UseMagicCardRequestPacket
		. new(
			d["card_id"],
			CardPosition.from_array(d["target_position"]),
			d["hand_pos"],
		)
	)
