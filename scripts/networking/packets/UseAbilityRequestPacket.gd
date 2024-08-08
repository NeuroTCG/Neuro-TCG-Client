extends Packet
class_name UseAbilityRequestPacket

var target_position: CardPosition
var ability_position: CardPosition

func _init(target_position_: CardPosition, ability_position_: CardPosition):
	super(PacketType.AttackRequest)
	target_position = target_position_
	ability_position = ability_position_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"target_position": target_position.to_array(),
		"ability_position": ability_position.to_array(),
	}

static func from_dict(d: Dictionary):
	return UseAbilityRequestPacket.new(CardPosition.from_array(d["target_position"]), CardPosition.from_array(d["ability_position"]))
