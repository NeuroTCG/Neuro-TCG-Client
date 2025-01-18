extends Node

signal summon(packet: SummonPacket)
signal magic(packet: UseMagicCardPacket)
signal attack(packet: AttackPacket)
signal draw_card(packet: DrawCardPacket)
signal switch(packet: SwitchPlacePacket)
signal ability(packet: UseAbilityPacket)
signal deck_master_init(packet: DeckMasterPacket)

signal opponent_finished
