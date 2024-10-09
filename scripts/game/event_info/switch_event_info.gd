extends Node

##Contains all the information about PassiveEventManager's 'card_switched_with_another' event.
class_name SwitchEventInfo

#The Card that preformed the switch
#(i.e, which card the player selected before performing the switch)
var switcher: Card

#The Card that is being switched with the switcher.
var switchee: Card

#The slot where the switcher was in before the switch occurred.
var old_slot: CardSlot

#The slot where the switcher was in after the switch occurred.
var new_slot: CardSlot

func _init(_switcher: Card, _switchee: Card, _old_slot: CardSlot, _new_slot: CardSlot):
	switcher = _switcher;
	switchee = _switchee;
	old_slot = _old_slot;
	new_slot = _new_slot;
