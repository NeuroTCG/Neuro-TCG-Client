extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)
	VerifyClientAction.player_finished.connect(_on_player_finished)

	if MatchManager._opponent_turn:
		text = "Opponent's Turn"
	else:
		text = "Your Turn"


func _on_opponent_finished() -> void:
	text = "Your Turn"


func _on_player_finished() -> void:
	text = "Opponent's Turn"
