##Contains information related to PassiveEventManager's heal-related events,
##like card_dealt_healing or card_received_healing.
class_name HealEventInfo
extends EventInfo

#A Possible source of damage.
enum HealSource {
	ABILITY,
	PASSIVE
}

#The amount of damage that was dealt.
var amount: int

#Where the damage came from.
var source: HealSource

func _init(_healer: CardPosition, _healees: Array[CardPosition], _amount: int, _source: HealSource):
	super(_healer, _healees)
	amount = _amount;
	source = _source;

func heal_source_as_string(source: HealSource) :
	match HealSource:
		HealSource.ABILITY:
			return "ability"
		HealSource.PASSIVE:
			return "passive"
		_:
			assert(false, "tried to convert an unkown heal source type into a string!")

func to_dict() -> Dictionary:
	return {
		"event_type" : PassiveEventManager.DamageEvent,
		"user_position" : user_position.to_array(),
		"target_positions" : targets_array(),
		"healing_amount" : amount,
		"healing_source" : heal_source_as_string(source)
	}
