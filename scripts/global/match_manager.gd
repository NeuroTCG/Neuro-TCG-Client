## Manges match and who goes first and player actions 
extends Node

signal action_summon
signal action_switch 
signal action_attack 
signal action_view

enum Actions {
	SUMMON,
	SWITCH, 
	ATTACK,
	ABILITY,
	VIEW,
	IDLE  
}

var input_paused := false 
var current_action := Actions.IDLE:
	set(new_action):
		current_action = new_action 
		match new_action: 
			Actions.SUMMON:
				action_summon.emit() 
			Actions.SWITCH:
				action_switch.emit() 
			Actions.ATTACK:
				action_attack.emit() 
			Actions.VIEW:
				action_view.emit()

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
	
	current_action = Actions.IDLE 
	
func _on_opponent_finished() -> void:
	input_paused = false 

func _on_player_finished() -> void:
	input_paused = true
