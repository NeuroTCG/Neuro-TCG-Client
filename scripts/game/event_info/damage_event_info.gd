##Contains information related to PassiveEventManager's damage-related events.
class_name DamageEventInfo
extends EventInfo

#A Possible source of damage.
enum DamageSource {
	NONE,
	ATTACK,
	COUNTER_ATTACK,
	ABILITY,
	PASSIVE
}

#The amount of damage that was dealt.
var amount: int

#Where the damage came from.
var source: DamageSource

func _init(_attacker: CardPosition, _victims: Array[CardPosition], _amount: int, _source: DamageSource):
	super(_attacker, _victims);
	amount = _amount;
	source = _source;

func to_dict() -> Dictionary:
	return {
		"event_type" : PassiveEventManager.DamageEvent,
		"user_position" : user_position.to_array(),
		"target_positions" : targets_array(),
		"damage_amount" : amount,
		"damage_source" : damage_source_as_string(source)
	}

func damage_source_as_string(source: DamageSource):
	match source:
		DamageSource.ATTACK:
			return "attack"
		DamageSource.COUNTER_ATTACK:
			return "counter_attack"
		DamageSource.PASSIVE:
			return "passive"
		DamageSource.ABILITY:
			return "ability"
		DamageSource.NONE:
			return "none"
		_:
			assert(false, "tried to convert an unkown damage source type into a string!")


func was_counterattack() -> bool:
	return source == DamageSource.COUNTER_ATTACK

func _to_string():
	return "DamageEvent: %s dealt %d damage to %s by way of %s!" % [user_position, amount, target_positions, source]
