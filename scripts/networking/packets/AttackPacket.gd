extends Packet
class_name AttackPacket

class Response:
	extends Packet

	var response_id: int
	var valid: bool
	var target_card: CardState
	var attacker_card: CardState

	func _init(valid_: bool, target_card_: CardState, attacker_card_: CardState, response_id_: int=Packet.get_next_response_id()):
		super(PacketType.AttackResponse)
		valid = valid_
		target_card = target_card_
		attacker_card = attacker_card_
		response_id = response_id_

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"response_id": response_id,
			"attacker_card": attacker_card.to_dict(),
			"target_card": target_card.to_dict(),
			"vaild": valid,
		}

	func get_response_id() -> int:
		return response_id
		
	static func from_dict(d: Dictionary):
		if d["valid"]:
			return AttackPacket.Response.new(d["valid"], CardState.from_dict(d["target_card"]), CardState.from_dict(d["attacker_card"]), d["response_id"])
		else:
			return AttackPacket.Response.new(d["valid"], null, null, d["response_id"])

class Opponent:
	extends Packet

	var target_position: CardPosition
	var attacker_position: CardPosition
	var target_card: CardState
	var attacker_card: CardState

	func _init(target_position_: CardPosition, attacker_position_: CardPosition, target_card_: CardState, attacker_card_: CardState):
		super(PacketType.AttackOpponent)
		target_position = target_position_
		attacker_position = attacker_position_
		target_card = target_card_
		attacker_card = attacker_card_

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"target_card": target_card.to_dict(),
			"attacker_card": attacker_card.to_dict(),
			"target_position": target_position.to_array(),
			"attacker_position": attacker_position.to_array(),
		}

	static func from_dict(d: Dictionary):
		return AttackPacket.Opponent.new(CardPosition.from_array(d["target_position"]), CardPosition.from_array(d["attacker_position"]), CardState.from_dict(d["target_card"]), CardState.from_dict(d["attacker_card"]))

var response_id: int
var target_position: CardPosition
var attacker_position: CardPosition

func _init(target_position_: CardPosition, attacker_position_: CardPosition, response_id_: int=Packet.get_next_response_id()):
	super(PacketType.Attack)
	response_id = response_id_
	target_position = target_position_
	attacker_position = attacker_position_

func to_dict() -> Dictionary:
	return {
		"type": type,
		"response_id": response_id,
		"target_position": target_position.to_array(),
		"attacker_position": attacker_position.to_array(),
	}

func get_response_id() -> int:
	return response_id

static func from_dict(d: Dictionary):
	return AttackPacket.new(CardPosition.from_array(d["target_position"]), CardPosition.from_array(d["attacker_position"]), d["response_id"])
