extends Node

signal player_finished


func _ready() -> void:
	player_finished.connect(_on_player_finished)


func summon(card_id: int, position: Array[int]) -> bool:
	print("Summon")
	var response: SummonPacket = await Global.network_manager.send_packet_and_await_response(
		SummonRequestPacket.new(
			Packet.next_response_id(), card_id, CardPosition.from_array(position)
		)
	)
	return response.valid


func magic(card_id: int, target_position: CardPosition, hand_pos: int) -> bool:
	print("Magic")
	var response: UseMagicCardPacket = await Global.network_manager.send_packet_and_await_response(
		UseMagicCardRequestPacket.new(Packet.next_response_id(), card_id, target_position, hand_pos)
	)
	return response.valid


func attack(_card_id: int, target_pos: Array[int], attack_pos: Array[int]) -> AttackPacket:
	print("Attack")
	var response: AttackPacket = await Global.network_manager.send_packet_and_await_response(
		AttackRequestPacket.new(
			Packet.next_response_id(),
			CardPosition.from_array(target_pos),
			CardPosition.from_array(attack_pos)
		)
	)
	return response


func _on_player_finished() -> void:
	Global.network_manager.send_packet(EndTurnPacket.new())


func switch(pos1: Array[int], pos2: Array[int]) -> bool:
	print("Switch")
	var response: SwitchPlacePacket = await Global.network_manager.send_packet_and_await_response(
		SwitchPlaceRequestPacket.new(
			Packet.next_response_id(), CardPosition.from_array(pos1), CardPosition.from_array(pos2)
		)
	)
	return response.valid


func ability(target_pos: Array[int], ability_pos: Array[int]) -> bool:
	print("Ability")
	var response: UseAbilityPacket = await Global.network_manager.send_packet_and_await_response(
		UseAbilityRequestPacket.new(
			Packet.next_response_id(),
			CardPosition.from_array(target_pos),
			CardPosition.from_array(ability_pos)
		)
	)
	return response.valid
