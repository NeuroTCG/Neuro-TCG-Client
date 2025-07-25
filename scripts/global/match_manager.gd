## Manges match and who goes first and player actions
extends Node

signal action_summon
signal action_switch
signal action_attack
signal action_ability
signal action_magic
## View is handeled separately compared to any other other action
signal action_view(card: Card)

# From HUD
signal request_end_turn

enum Actions {
	SUMMON,
	SWITCH,
	ATTACK,
	ABILITY,
	VIEW,
	IDLE,
	MAGIC,
}

var input_paused := false
## Don't set this variable outside of match manager.
## For pausing input unrelated to the player turn use input_paused instead
var _opponent_turn := false
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
			Actions.ABILITY:
				action_ability.emit()
			Actions.MAGIC:
				action_magic.emit()
var first_player := false


func _ready() -> void:
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)
	VerifyClientAction.player_finished.connect(_on_player_finished)
	await Global.network_manager_ready
	Global.network_manager.match_found.connect(_on_match_found)
	request_end_turn.connect(end_turn)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("end_turn"):
		end_turn()


func end_turn() -> void:
	if _opponent_turn:  # Can't end turn when its the opponent's turn ofc
		return

	print("Ending player turn")
	for callable in Global.mouse_input_functions:
		callable.call()
	VerifyClientAction.player_finished.emit()


func player_index():
	if first_player:
		return 0
	else:
		return 1


func _on_match_found(packet: MatchFoundPacket) -> void:
	if packet.is_first_player:
		print("THIS PLAYER WILL GO FIRST")
		first_player = true
		_opponent_turn = false
	else:
		print("THIS PLAYER WILL GO SECOND")
		first_player = false
		_opponent_turn = true

	input_paused = false
	current_action = Actions.IDLE


func _on_opponent_finished() -> void:
	_opponent_turn = false


func _on_player_finished() -> void:
	_opponent_turn = true
