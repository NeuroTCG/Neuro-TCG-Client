class_name CardActionTarget

var playerIdx: int
var position: CardPosition


func _init(_playerIdx: int, _position: CardPosition):
	playerIdx = _playerIdx
	position = _position


static func from_dict(d: Dictionary) -> CardActionTarget:
	return CardActionTarget.new(d["playerIdx"], CardPosition.from_array(d["position"]))


func _to_string() -> String:
	return "CardActionTarget: {playerIdx: %d, position: %s}" % [playerIdx, position]
