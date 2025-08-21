class_name SummonPacket
extends PacketWithResponseId

var valid: bool
var is_you: bool
var position: CardPosition
var new_card: CardData
var new_ram: int


func _init(
	response_id_: int,
	is_you_: bool,
	valid_: bool,
	position_: CardPosition,
	new_card_: CardData,
	new_ram_: int
) -> void:
	super(PacketType.Summon, response_id_)
	is_you = is_you_
	valid = valid_
	position = position_
	new_card = new_card_
	new_ram = new_ram_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"is_you": is_you,
				"valid": valid,
				"position": position.to_array(),
				"new_card": new_card.to_dict(),
				"new_ram": new_ram,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> SummonPacket:
	return SummonPacket.new(
		d["response_id"],
		d["is_you"],
		d["valid"],
		CardPosition.from_array(d["position"]),
		CardData.from_dict(d["new_card"]),
		d["new_ram"]
	)
