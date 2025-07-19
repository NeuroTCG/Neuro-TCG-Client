## Updates and stores info on each card
extends Node

var card_info_dict := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Global.network_manager_ready
	Global.network_manager.rule_info.connect(_on_rule_info)


func _on_rule_info(packet: RuleInfoPacket) -> void:
	card_info_dict = packet.card_id_mapping
	Global.card_info_received.emit()


func get_deck_master_ids() -> Array[int]:
	var ret: Array[int] = []
	for c: int in card_info_dict.keys():
		print(card_info_dict[c])
		if (card_info_dict[c].card_type == CardStats.CardType.DECK_MASTER and (not is_not_implemented(c))):
			ret.append(c)
	return ret

#Check if a card's passive or ability has not been implemented.
func is_not_implemented(id: int) -> bool:
	return (
		card_info_dict[id].ability.effect == Ability.AbilityEffect.NOT_IMPLEMENTED
		or card_info_dict[id].passive.effect == Passive.PassiveEffectType.NOT_IMPLEMENTED
	)

func is_deck_master(id: int) -> bool:
	assert(id in card_info_dict.keys(), "Could not find card with id: %s" % [id])
	return card_info_dict[id].card_type == CardStats.CardType.DECK_MASTER
