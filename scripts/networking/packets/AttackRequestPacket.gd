extends PacketWithResponseId
class_name AttackRequestPacket

var target_position: CardPosition
var attacker_position: CardPosition


func _init(
	response_id_: int, target_position_: CardPosition, attacker_position_: CardPosition
) -> void:
	super(PacketType.AttackRequest, response_id_)
	target_position = target_position_
	attacker_position = attacker_position_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"target_position": target_position.to_array(),
				"attacker_position": attacker_position.to_array(),
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> AttackRequestPacket:
	return AttackRequestPacket.new(
		d["response_id"],
		CardPosition.from_array(d["target_position"]),
		CardPosition.from_array(d["attacker_position"])
	)
