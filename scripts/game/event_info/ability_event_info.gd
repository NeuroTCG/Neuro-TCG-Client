class_name AbilityEventInfo
extends EventInfo

var ability_used: Ability

func _init(_user: CardPosition, _targets: Array[CardPosition], _ability_used: Ability):
	super(_user, _targets);
	ability_used = _ability_used;

func to_dict():
	return {
		"event_type" : PassiveEventManager.AbilityEvent,
		"user_position" : user_position.to_array(),
		"target_positions" : targets_array(),
		"ability_used" : ability_used.to_dict()
	}

func _to_string():
	return "AbilityEvent: %s used an ability on %s!" % [user_position, target_positions]
