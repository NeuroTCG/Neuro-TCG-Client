# TODO: figure out what this does
extends Node2D
class_name Game

const PLAYER_WON = "You won! Congratulations!"
const PLAYER_LOST = "You lost :("

var game_over_template = preload("res://scenes/ui/game_over.tscn")


func _ready() -> void:
	Global.network_manager.game_over.connect(_on_game_over)


func _on_game_over(packet: GameOverPacket) -> void:
	var game_over = game_over_template.instantiate()

	game_over.get_node("WinLabel").text = PLAYER_WON if packet.you_are_winner else PLAYER_LOST
	get_tree().root.add_child(game_over)

	queue_free()
