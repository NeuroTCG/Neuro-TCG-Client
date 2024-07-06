extends Node

signal summon(card_id: int, position: Array)
signal attack(card_id: int, target_position: Array, attacker_position: Array) 

func _ready() -> void:
	summon.connect(_on_summon)
	attack.connect(_on_attack)

func _on_summon(card_id, position) -> void:
	# TODO: Use info to create a packet and send data to server 
	
	pass 
	
func _on_attack(card_id, target_pos, attack_pos) -> void:
	# TODO: Use info to create a packet and send data to server 
	
	pass

