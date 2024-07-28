class_name SummonPacket
extends Packet

var valid: bool
var is_you: bool
var position: CardPosition
var new_card: CardState
var new_ram: int

func _init(is_you_: bool, valid_: bool, position_: CardPosition, new_card_: CardState, new_ram_: int):
	super(PacketType.Summon)
	is_you = is_you_
	valid = valid_
	position = position_
	new_card = new_card_
	new_ram = new_ram_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"is_you": is_you,
		"valid": valid,
		"position": position.to_array(),
		"new_card": new_card.to_dict(),
		"new_ram": new_ram,
	}

static func from_dict(d: Dictionary):
	return SummonPacket.new(d["is_you"], d["valid"], CardPosition.from_array(d["position"]), CardState.from_dict(d["new_card"]), d["new_ram"])
