extends Packet
class_name AttackRequestPacket

var target_position: CardPosition
var attacker_position: CardPosition
var counterattack: bool 

func _init(target_position_: CardPosition, attacker_position_: CardPosition, counterattack_ := false):
	super(PacketType.AttackRequest)
	target_position = target_position_
	attacker_position = attacker_position_
	counterattack = counterattack_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"target_position": target_position.to_array(),
		"attacker_position": attacker_position.to_array(),
		"counterattack": counterattack 
	}

static func from_dict(d: Dictionary):
	return AttackRequestPacket.new(CardPosition.from_array(d["target_position"]), CardPosition.from_array(d["attacker_position"]), d["counterattack"])
