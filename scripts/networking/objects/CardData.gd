class_name CardData

var playerIdx: int
var position: CardPosition
var state: CardState


func _init(_playerIdx: int, _position: CardPosition, _state: CardState):
	playerIdx = _playerIdx
	position = _position
	state = _state


static func from_dict(d) -> CardData:
	if (d == null):
		return null
	return CardData.new(
		d["playerIdx"], CardPosition.from_array(d["position"]), CardState.from_dict(d["state"])
	)

func to_dict() -> Dictionary:
	return {
		"playerIdx": playerIdx,
		"position": position.to_array(),
		"state": state.to_dict()
	}

func _to_string() -> String:
	return "CardData: {player: %s, position: %s, state: %s}" % [playerIdx, position, state]
