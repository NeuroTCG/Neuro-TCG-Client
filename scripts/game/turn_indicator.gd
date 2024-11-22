extends Label

const YOUR_TURN := "Your Turn"
const NOT_YOUR_TURN := "Opponent's Turn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)
	VerifyClientAction.player_finished.connect(_on_player_finished)
	Global.board_state_loaded.connect(_on_game_loaded)

	if MatchManager._opponent_turn:
		text = NOT_YOUR_TURN
	else:
		text = YOUR_TURN


func _on_opponent_finished() -> void:
	text = YOUR_TURN


func _on_player_finished() -> void:
	text = NOT_YOUR_TURN


func _on_game_loaded() -> void:
	if MatchManager._opponent_turn:
		text = NOT_YOUR_TURN
	else:
		text = YOUR_TURN
