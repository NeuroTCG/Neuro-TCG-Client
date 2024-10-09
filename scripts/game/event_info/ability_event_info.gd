extends Node
class_name AbilityEventInfo

#The card that performed the ability.
var ability_card: Card

#The cards that the ability was applied to.
var ability_target: Card

func _init(_ability_card: Card, _ability_target: Card):
	ability_card = _ability_card
	ability_target = _ability_target

func _to_string():
	return "AbilityEvent: %s used an ability on %s!" % [ability_card, ability_target]
