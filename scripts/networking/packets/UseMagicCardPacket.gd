class_name UseMagicCardPacket
extends PacketWithResponseId

var valid: bool
var is_you: bool
var hand_pos: int
var ability: Ability
var target_position: CardPosition
var target_card: CardState


func _init(
	response_id_: int,
	is_you_: bool,
	valid_: bool,
	hand_pos_: int,
	ability_: Ability,
	target_position_: CardPosition,
	target_card_: CardState
) -> void:
	super(PacketType.UseMagicCard, response_id_)
	is_you = is_you_
	valid = valid_
	hand_pos = hand_pos_
	target_position = target_position_
	ability = ability_
	target_card = target_card_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"is_you": is_you,
				"valid": valid,
				"hand_pos": hand_pos,
				"ability": ability,
				"target_position": target_position,
				"target_card": target_card,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> UseMagicCardPacket:
	return UseMagicCardPacket.new(
		d["response_id"],
		d["is_you"],
		d["valid"],
		d["hand_pos"],
		Ability.from_dict(d["ability"]),
		CardPosition.from_array(d["target_position"]),
		CardState.from_dict(d["target_card"])
	)
