extends Node2D

var player_max_ram := 0
var player_ram: int
var opponent_max_ram := 0
var opponent_ram: int

func _ready() -> void:	
	add_to_group("ram_manager")
	
	RenderOpponentAction.opponent_finished.connect(_refresh_player_ram)
	VerifyClientAction.player_finished.connect(_refresh_opponent_ram)
	Global.use_ram.connect(_on_use_ram)

	if MatchManager.first_player:
		player_max_ram += 1 
		player_ram = player_max_ram
		Global.update_ram.emit(player_ram)
	else:
		opponent_max_ram += 1
		opponent_ram = opponent_max_ram
		Global.update_enemy_ram.emit(opponent_ram)

func _refresh_player_ram() -> void:
	if player_max_ram != 10:
		player_max_ram += 1 
	player_ram = player_max_ram 
	Global.update_ram.emit(player_ram) 

func _refresh_opponent_ram() -> void:
	if opponent_max_ram != 10:
		opponent_max_ram += 1 
	opponent_ram = opponent_max_ram 
	Global.update_enemy_ram.emit(opponent_ram)

func _on_use_ram(value: int) -> void:
	player_ram -= value
	Global.update_ram.emit(player_ram)
