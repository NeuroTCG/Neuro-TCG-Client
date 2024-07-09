extends Node2D


func _ready() -> void:
	# Rudimentary gameplay example, with set actions for the opponent. 
	User.match_found.emit(MatchFoundPacket.new(UserInfo.new("", ""), 0, true, false))
	
	await get_tree().create_timer(1.0).timeout 
	
	# Turn 1 (Opponent) 
	var test_summon_packet = SummonPacket.new(true, true, CardPosition.new(0,0), CardState.new(0, 100))
	RenderOpponentAction.summon.emit(test_summon_packet)
	RenderOpponentAction.opponent_finished.emit() 
	
	# Turn 2 (Player)
	await VerifyClientAction.player_finished
	
	# Turn 3 (Opponent)
	var test_summon_packet2 = SummonPacket.new(true, true, CardPosition.new(1,0), CardState.new(1, 100))
	RenderOpponentAction.summon.emit(test_summon_packet2)
	RenderOpponentAction.opponent_finished.emit() 
	
	# Turn 4 (Player) 
	await VerifyClientAction.player_finished 
	
	assert(false, "No more gameplay implemented")
