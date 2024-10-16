extends Node2D
class_name RamManager

var player_max_ram := 0
var player_ram: int
var opponent_max_ram := 0
var opponent_ram: int


func _ready() -> void:
	add_to_group("ram_manager")

	RenderOpponentAction.opponent_finished.connect(_refresh_opponent_ram)
	VerifyClientAction.player_finished.connect(_refresh_player_ram)
	Global.use_ram.connect(_on_use_ram)
	Global.use_enemy_ram.connect(_on_use_enemy_ram)

	player_ram = player_max_ram
	Global.player_ram_changed.emit(player_ram)
	Global.update_max_ram.emit(player_max_ram)

	opponent_ram = opponent_max_ram
	Global.enemy_ram_changed.emit(opponent_ram)
	Global.update_enemy_max_ram.emit(opponent_max_ram)


func reset_ram(is_player_first: bool) -> void:
	player_max_ram = 0
	opponent_max_ram = 0

	if !is_player_first:
		_refresh_opponent_ram()

	_refresh_player_ram()


func _refresh_player_ram() -> void:
	if player_max_ram < 10:
		player_max_ram += 1
		Global.update_max_ram.emit(player_max_ram)
	player_ram = player_max_ram
	Global.player_ram_changed.emit(player_ram)


func _refresh_opponent_ram() -> void:
	if opponent_max_ram < 10:
		opponent_max_ram += 1
		Global.update_enemy_max_ram.emit(opponent_max_ram)
	opponent_ram = opponent_max_ram
	Global.enemy_ram_changed.emit(opponent_ram)


func _on_use_ram(value: int) -> void:
	player_ram -= value
	Global.player_ram_changed.emit(player_ram)


func _on_use_enemy_ram(value: int) -> void:
	opponent_ram -= value
	Global.enemy_ram_changed.emit(opponent_ram)
