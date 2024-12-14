class_name UseMagicCardPacket
extends Packet

var valid: bool
var is_you: bool
var hand_pos: int
var ability: Ability
var target_position: CardPosition
var target_card: CardState


func _init(
	is_you_: bool,
	valid_: bool,
	hand_pos_: int,
	ability_: Ability,
	target_position_: CardPosition,
	target_card_: CardState
) -> void:
	super(PacketType.UseMagicCard)
	is_you = is_you_
	valid = valid_
	hand_pos = hand_pos_
	target_position = target_position_
	ability = ability_
	target_card = target_card_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"is_you": is_you,
		"valid": valid,
		"hand_pos": hand_pos,
		"ability": ability,
		"target_position": target_position,
		"target_card": target_card,
	}


static func from_dict(d: Dictionary) -> UseMagicCardPacket:
	return UseMagicCardPacket.new(
		d["is_you"],
		d["valid"],
		d["hand_pos"],
		Ability.from_dict(d["ability"]),
		CardPosition.from_array(d["target_position"]),
		CardState.from_dict(d["target_card"])
	)
