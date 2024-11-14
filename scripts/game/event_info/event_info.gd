class_name EventInfo

var user_position: CardPosition
var target_positions: Array[CardPosition]

func _init(_user: CardPosition, _targets: Array[CardPosition]):
	user_position = _user;
	target_positions = _targets;
	pass

func to_dict() -> Dictionary:
	assert(false, "This script which extends EventInfo has not overidden their to_dict() function")
	return {}

func targets_array() -> Array[Array]:
	var ret: Array[Array] = [];
	for t in target_positions:
		ret.append(t.to_array());
	return ret;
