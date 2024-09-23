extends Node

signal summon(packet: SummonPacket)
signal attack(packet: AttackPacket)
signal draw_card(packet: DrawCardPacket)
signal switch(packet: SwitchPlacePacket)
signal ability(packet: UseAbilityPacket)

signal opponent_finished
