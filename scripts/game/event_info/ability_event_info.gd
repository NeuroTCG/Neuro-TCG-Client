extends Node
class_name AbilityEventInfo

#The card that performed the ability.
var ability_card: Card

#The cards that the ability was applied to.
var ability_targets: Dictionary

func _init(_ability_card: Card, _ability_targets: Dictionary):
	ability_card = _ability_card
	ability_targets = _ability_targets

func _to_string():
	return "AbilityEvent: %s used an ability on %s!" % [ability_card, ability_targets]
