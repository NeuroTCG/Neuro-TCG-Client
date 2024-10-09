extends Node

##Contains information related to PassiveEventManager's heal-related events,
##like card_dealt_healing or card_received_healing.
class_name HealEventInfo

#A Possible source of damage.
enum HealSource {
	ABILITY,
	PASSIVE
}

#The Card that dealt the damage.
var healer: Card

#The Card that received the damage.
var healee: Card

#The amount of damage that was dealt.
var amount: int

#Where the damage came from.
var source: HealSource

func _init(_healer: Card, _healee: Card, _amount: int, _source: HealSource):
	healer = _healer;
	healee = _healee;
	amount = _amount;
	source = _source;
