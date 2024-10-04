class_name AttackPacket
extends Packet

var is_you: bool
var valid: bool
var target_position: CardPosition
var attacker_position: CardPosition
var target_card: CardState
var attacker_card: CardState


func _init(
	is_you_: bool,
	valid_: bool,
	target_position_: CardPosition,
	attacker_position_: CardPosition,
	target_card_: CardState,
	attacker_card_: CardState
) -> void:
	super(PacketType.Attack)
	is_you = is_you_
	valid = valid_
	target_position = target_position_
	attacker_position = attacker_position_
	target_card = target_card_
	attacker_card = attacker_card_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"is_you": is_you,
		"valid": valid,
		"target_position": target_position.to_array(),
		"attacker_position": attacker_position.to_array(),
		"target_card": target_card.to_dict(),
		"attacker_card": attacker_card.to_dict(),
	}


static func from_dict(d: Dictionary) -> AttackPacket:
	return AttackPacket.new(
		d["is_you"],
		d["valid"],
		CardPosition.from_array(d["target_position"]),
		CardPosition.from_array(d["attacker_position"]),
		CardState.from_dict(d["target_card"]),
		CardState.from_dict(d["attacker_card"])
	)
