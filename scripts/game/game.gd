extends Node2D

func _ready() -> void:
	
	printerr("Comment out following function for testing w server")
	example_gameplay()

func example_gameplay() -> void:
	# Turn 1 (Opponent) 
	var test_summon_packet = SummonPacket.new(true, true, CardPosition.new(0,0), CardState.new(0, 100))
	var test_summon_packet2 = SummonPacket.new(true, true, CardPosition.new(1,0), CardState.new(1, 100))
	RenderOpponentAction.summon.emit(test_summon_packet)
	RenderOpponentAction.summon.emit(test_summon_packet2)
	RenderOpponentAction.opponent_finished.emit() 
	
	# Turn 2 (Player)
	await VerifyClientAction.player_finished
	
