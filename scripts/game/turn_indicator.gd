extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)
	VerifyClientAction.player_finished.connect(_on_player_finished)

	await get_tree().create_timer(0.5).timeout
	if (MatchManager.input_paused):
		text = "Opponent's Turn"
	else:
		text = "Your Turn"

func _on_opponent_finished() -> void:
	text = "Your Turn"
	
func _on_player_finished() -> void:
	text = "Opponent's Turn"
