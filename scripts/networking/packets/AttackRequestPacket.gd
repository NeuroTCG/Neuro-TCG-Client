extends Packet
class_name AttackRequestPacket

var target_position: CardPosition
var attacker_position: CardPosition

func _init(target_position_: CardPosition, attacker_position_: CardPosition):
	super(PacketType.AttackRequest)
	target_position = target_position_
	attacker_position = attacker_position_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"target_position": target_position.to_array(),
		"attacker_position": attacker_position.to_array(),
	}

static func from_dict(d: Dictionary):
	return AttackRequestPacket.new(CardPosition.from_array(d["target_position"]), CardPosition.from_array(d["attacker_position"]))
