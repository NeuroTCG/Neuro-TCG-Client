extends Node

##Contains all the information about PassiveEventManager's 'card_moved' event.
class_name MoveEventInfo

#The card that is being moved.
var card: Card

#The slot where the card previously was.
var old_slot: CardSlot

#The slot the card was moved to.
var new_slot: CardSlot

func _init(_card: Card, _old_slot: CardSlot, _new_slot: CardSlot):
	card = _card;
	old_slot = _old_slot;
	new_slot = _new_slot;
