class_name CardAction

var action_name: String
var targets: Array[CardPosition]
var amount: int

func _init(_action_name: String, _targets: Array[CardPosition], _amount: int):
	action_name = _action_name;
	targets = _targets;
	amount = _amount;
