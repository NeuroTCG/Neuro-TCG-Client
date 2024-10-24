extends Node

##Contains signals for specific situations to help facilitate card passives.

#Damage and Kills
signal card_was_damaged(event_info: DamageEventInfo)
signal card_dealt_final_blow(event_info: DamageEventInfo)

#Healing
signal card_was_healed(event_info: HealEventInfo)

#Movement/Switching
signal card_switched_with_another(event_info: SwitchEventInfo)
signal card_moved(event_info: MoveEventInfo)

#Abilities
signal card_ability_used(event_info: AbilityEventInfo)
