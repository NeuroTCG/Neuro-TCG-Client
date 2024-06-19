extends Packet
class_name SummonPacket

class Response:
	extends Packet

	var response_id: int
	var valid: bool
	var new_card: CardState

	func _init(valid_: bool, new_card_: CardState, response_id_: int=Packet.get_next_response_id()):
		super(PacketType.SummonResponse)
		valid = valid_
		new_card = new_card_
		response_id = response_id_

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"response_id": response_id,
			"new_card": new_card.to_dict(),
			"vaild": valid,
		}

	func get_response_id() -> int:
		return response_id
	
	static func from_dict(d: Dictionary):
		if d["new_card"] != null:
			return SummonPacket.Response.new(d["valid"], CardState.from_dict(d["new_card"]), d["response_id"])
		else:
			return SummonPacket.Response.new(d["valid"], null, d["response_id"])

class Opponent:
	extends Packet

	var position: CardPosition
	var new_card: CardState

	func _init(position_: CardPosition, new_card_: CardState):
		super(PacketType.SummonOpponent)
		position = position_
		new_card = new_card_

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"new_card": new_card.to_dict(),
			"position": position.to_array(),
		}

	static func from_dict(d: Dictionary):
		return SummonPacket.Opponent.new(CardPosition.from_array(d["position"]), CardState.from_dict(d["new_card"]))

var response_id: int
var card_id: int
var position: CardPosition

func _init(card_id_: int, position_: CardPosition, response_id_: int=Packet.get_next_response_id()):
	super(PacketType.Summon)
	response_id = response_id_
	card_id = card_id_
	position = position_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"response_id": response_id,
		"card_id": card_id,
		"position": position.to_array(),
	}

func get_response_id() -> int:
	return response_id

static func from_dict(d: Dictionary):
	return SummonPacket.new(d["card_id"], CardPosition.from_array(d["position"]), d["response_id"])
