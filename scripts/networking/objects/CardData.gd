class_name CardData

var position: CardPosition
var state: CardState


func _init(_position: CardPosition, _state: CardState):
	position = _position
	state = _state


static func from_dict(d: Dictionary) -> CardData:
	return CardData.new(CardPosition.from_array(d["position"]), CardState.from_dict(d["state"]))


func _to_string() -> String:
	return "CardData: {position: %s, state: %s}" % [position.to_array(), state]
