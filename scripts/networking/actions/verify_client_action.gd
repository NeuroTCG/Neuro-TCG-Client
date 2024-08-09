extends Node

signal summon(card_id: int, position: Array)
signal attack(card_id: int, target_position: Array, attacker_position: Array)
signal switch(pos1: Array, pos2: Array)
signal ability(target_position: Array, ability_position: Array)

signal player_finished

func _ready() -> void:
	summon.connect(_on_summon)
	attack.connect(_on_attack)
	player_finished.connect(_on_player_finished)
	switch.connect(_on_switch)
	ability.connect(_on_ability)

func _on_summon(card_id, position) -> void:
	print("Summon")
	User.send_packet(SummonRequestPacket.new(card_id, CardPosition.from_array(position)))
	
func _on_attack(_card_id, target_pos, attack_pos) -> void:
	print("Attack")
	User.send_packet(AttackRequestPacket.new(CardPosition.from_array(target_pos), CardPosition.from_array(attack_pos)))

func _on_player_finished() -> void:
	User.send_packet(EndTurnPacket.new())

func _on_switch(pos1, pos2) -> void:
	print("Switch")
	User.send_packet(SwitchPlaceRequestPacket.new(CardPosition.from_array(pos1), CardPosition.from_array(pos2)))

func _on_ability(target_pos, ability_pos) -> void:
	print("Ability")
	User.send_packet(UseAbilityRequestPacket.new(CardPosition.from_array(target_pos), CardPosition.from_array(ability_pos)))