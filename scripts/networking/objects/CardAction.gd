class_name CardAction

var action_name: String
var targets: Array[CardActionTarget]
var amount: int


func _init(_action_name: String, _targets: Array[CardActionTarget], _amount: int):
	action_name = _action_name
	targets = _targets
	amount = _amount


static func from_dict(d: Dictionary) -> CardAction:
	var target_array: Array[CardActionTarget] = []
	for t in d["targets"]:
		target_array.append(CardActionTarget.from_dict(t))
	return CardAction.new(d["action_name"], target_array, d["amount"])
