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
		if (card_info_dict[c].card_type == CardStats.CardType.DECK_MASTER):
			ret.append(c)
	return ret
