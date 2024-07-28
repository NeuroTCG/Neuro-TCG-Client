## Updates and stores info on each card 
extends Node

var card_info_dict = {
	0: CardInfo.new(
		preload("res://assets/game/cards/evil.jpg"), 
		2,  # hp
		2,  # atk 
		2,  # cost
		CardInfo.AttackRange.STANDARD  # attack range 
	),
	1: CardInfo.new(
		preload("res://assets/game/cards/Fily.png"), 
		3,  # hp
		3,  # atk 
		5,  # cost
		CardInfo.AttackRange.REACH  # attack range 
	),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	User.rule_info.connect(_on_rule_info) 

func _on_rule_info(packet: RuleInfoPacket) -> void:
	var card_mapping = packet.card_id_mapping
	
	for id in card_mapping:
		var card_info: CardInfo = card_info_dict[int(id)]
		card_info.set_info(card_mapping[id].max_hp, card_mapping[id].base_atk)
