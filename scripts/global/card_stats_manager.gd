## Updates and stores info on each card 
extends Node

var card_info_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	User.rule_info.connect(_on_rule_info) 

func _on_rule_info(packet: RuleInfoPacket) -> void:
	var card_mapping = packet.card_id_mapping
	
	card_info_dict = card_mapping
