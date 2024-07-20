extends Node

signal summon(packet: SummonPacket)
signal attack(packet: AttackPacket)
signal draw_card(packet: DrawCardPacket)
signal switch(packet: SwitchPlacePacket)

signal opponent_finished 
