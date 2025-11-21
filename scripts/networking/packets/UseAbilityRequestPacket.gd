extends PacketWithResponseId
class_name UseAbilityRequestPacket

var target_position: CardPosition
var ability_position: CardPosition


func _init(
	response_id_: int, target_position_: CardPosition, ability_position_: CardPosition
) -> void:
	super(PacketType.UseAbilityRequest, response_id_)
	target_position = target_position_
	ability_position = ability_position_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"target_position": target_position.to_array(),
				"ability_position": ability_position.to_array(),
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> UseAbilityRequestPacket:
	return UseAbilityRequestPacket.new(
		d["response_id"],
		CardPosition.from_array(d["target_position"]),
		CardPosition.from_array(d["ability_position"])
	)
