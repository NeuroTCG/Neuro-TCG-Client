extends Node

##Contains information related to PassiveEventManager's damage-related events.
class_name DamageEventInfo

#A Possible source of damage.
enum DamageSource {
	NONE,
	ATTACK,
	COUNTER_ATTACK,
	ABILITY,
	PASSIVE
}

#The Card that dealt the damage.
var attacker: Card

#The Card that received the damage.
var victim: Card

#The amount of damage that was dealt.
var amount: int

#Where the damage came from.
var source: DamageSource

func _init(_attacker: Card, _victim: Card, _amount: int, _source: DamageSource):
	attacker = _attacker;
	victim = _victim;
	amount = _amount;
	source = _source;

func was_counterattack() -> bool:
	return source == DamageSource.COUNTER_ATTACK

func _to_string():
	return "DamageEvent: %s dealt %d damage to %s by way of %s!" % [attacker, amount, victim, source]
