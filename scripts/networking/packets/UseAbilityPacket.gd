class_name UseAbilityPacket

extends Packet

var is_you: bool
var valid: bool
var target_position: CardPosition
var ability_position: CardPosition
var target_card: CardState
var ability_card: CardState


func _init(
	is_you_: bool,
	valid_: bool,
	target_position_: CardPosition,
	ability_position_: CardPosition,
	target_card_: CardState,
	attacker_card_: CardState
):
	super(PacketType.UseAbility)
	is_you = is_you_
	valid = valid_
	target_position = target_position_
	ability_position = ability_position_
	target_card = target_card_
	ability_card = attacker_card_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"is_you": is_you,
		"valid": valid,
		"target_position": target_position.to_array(),
		"ability_position": ability_position.to_array(),
		"target_card": target_card.to_dict(),
		"ability_card": ability_card.to_dict(),
	}


static func from_dict(d: Dictionary):
	return UseAbilityPacket.new(
		d["is_you"],
		d["valid"],
		CardPosition.from_array(d["target_position"]),
		CardPosition.from_array(d["ability_position"]),
		CardState.from_dict(d["target_card"]),
		CardState.from_dict(d["ability_card"])
	)
