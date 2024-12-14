class_name CardAction

var action_name: String
var targets: Array[CardActionTarget]
var amount: int
var other_args: Array[CardActionArg]


func _init(_action_name: String, _targets: Array[CardActionTarget], _amount: int, _other_args: Array[CardActionArg]):
	action_name = _action_name
	targets = _targets
	amount = _amount
	other_args = _other_args


static func from_dict(d: Dictionary) -> CardAction:
	var target_array: Array[CardActionTarget] = []
	var args: Array[CardActionArg] = []
	for t in d["targets"]:
		target_array.append(CardActionTarget.from_dict(t))
	for a in d["other_args"]:
		args.append(CardActionArg.from_dict(a))
	return CardAction.new(d["action_name"], target_array, d["amount"], args)
