extends Node

signal summon(card_id: int, position: Array)
signal attack(card_id: int, target_position: Array, attacker_position: Array)

func _ready() -> void:
	summon.connect(_on_summon)
	attack.connect(_on_attack)

func _on_summon(card_id, position) -> void:
	print("Summon")
	User.send_packet(SummonRequestPacket.new(card_id, CardPosition.from_array(position)))
	
func _on_attack(_card_id, target_pos, attack_pos) -> void:
	print("Attack")
	User.send_packet(AttackRequestPacket.new(CardPosition.from_array(attack_pos), CardPosition.from_array(target_pos)))
