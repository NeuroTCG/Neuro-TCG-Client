class_name UseMagicCardPacket
extends Packet

var valid: bool
var is_you: bool
var ability_card_id: int
var target_card: CardState


func _init(
		is_you_: bool, valid_: bool, ability_card_id_: int, target_card_: CardState
) -> void:
	super(PacketType.UseMagicCard)
	is_you = is_you_
	valid = valid_
	ability_card_id = ability_card_id_
	target_card = target_card_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"is_you": is_you,
		"valid": valid,
		"ability_card_id": ability_card_id,
		"target_card": target_card,
	}


static func from_dict(d: Dictionary) -> UseMagicCardPacket:
	return UseMagicCardPacket.new(
		d["is_you"],
		d["valid"],
		d["ability_card_id"],
		d["target_card"]
	)
