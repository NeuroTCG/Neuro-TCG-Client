## Manges match and who goes first 
extends Node

var input_paused = false 

func _ready() -> void: 
	User.match_found.connect(_on_match_found)
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)
	VerifyClientAction.player_finished.connect(_on_player_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("end_turn"):
		VerifyClientAction.player_finished.emit() 

func _on_match_found(packet: MatchFoundPacket) -> void:
	if packet.is_first_player: 
		input_paused = false 
	else: 
		input_paused = true 
	
func _on_opponent_finished() -> void:
	input_paused = false 

func _on_player_finished() -> void:
	input_paused = true
