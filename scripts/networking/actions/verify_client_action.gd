extends Node

signal summon(card_id: int, position: Array)
signal magic(card_id: int, target_position: Array, hand_pos: int)
signal attack(card_id: int, target_position: Array, attacker_position: Array)
signal switch(pos1: Array, pos2: Array)
signal ability(target_position: Array, ability_position: Array)

signal player_finished


func _ready() -> void:
	summon.connect(_on_summon)
	magic.connect(_on_magic)
	attack.connect(_on_attack)
	player_finished.connect(_on_player_finished)
	switch.connect(_on_switch)
	ability.connect(_on_ability)


func _on_summon(card_id: int, position: Array[int]) -> void:
	print("Summon")
	Global.network_manager.send_packet(
		SummonRequestPacket.new(card_id, CardPosition.from_array(position))
	)


func _on_magic(card_id: int, target_position: Array[int], hand_pos: int) -> void:
	print("Magic")
	Global.network_manager.send_packet(
		UseMagicCardRequestPacket.new(card_id, CardPosition.from_array(target_position), hand_pos)
	)


func _on_attack(_card_id: int, target_pos: Array[int], attack_pos: Array[int]) -> void:
	print("Attack")
	Global.network_manager.send_packet(
		AttackRequestPacket.new(
			CardPosition.from_array(target_pos), CardPosition.from_array(attack_pos)
		)
	)


func _on_player_finished() -> void:
	Global.network_manager.send_packet(EndTurnPacket.new())


func _on_switch(pos1: Array[int], pos2: Array[int]) -> void:
	print("Switch")
	Global.network_manager.send_packet(
		SwitchPlaceRequestPacket.new(CardPosition.from_array(pos1), CardPosition.from_array(pos2))
	)


func _on_ability(target_pos: Array[int], ability_pos: Array[int]) -> void:
	print("Ability")
	Global.network_manager.send_packet(
		UseAbilityRequestPacket.new(
			CardPosition.from_array(target_pos), CardPosition.from_array(ability_pos)
		)
	)
