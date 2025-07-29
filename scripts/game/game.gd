extends Node2D
class_name Game

const PLAYER_WON = "You won! Congratulations!"
const PLAYER_LOST = "You lost :("


func _ready() -> void:
	Global.network_manager.game_over.connect(_on_game_over)
	Global.network_manager.opponent_ready.connect(_on_opponent_ready)
	Global.network_manager.send_packet(PlayerReadyPacket.new())
	Global.network_manager.disconnect.connect(_on_disconnect)
	Global.network_manager.connection.connection_failed.connect(_on_connection_failed)


func _on_opponent_ready(packet: OpponentReadyPacket) -> void:
	Global.network_manager.send_packet(OpponentReadyPacket.new())


func _on_game_over(packet: GameOverPacket) -> void:
	load_game_over(PLAYER_WON if packet.you_are_winner else PLAYER_LOST)


func _on_disconnect(packet: DisconnectPacket) -> void:
	load_game_over("Disconnect packet received: %s (%s)" % [packet.message, packet.reason])


func _on_connection_failed(url: String, error: String) -> void:
	load_game_over("Connection to %s failed: %s" % [url, error])


func load_game_over(message: String) -> void:
	var game_over = Global.game_over_template.instantiate()

	game_over.get_node("VBoxContainer/WinLabel").text = message
	get_tree().root.add_child(game_over)

	queue_free()

	# stop any connections
	Global.network_manager.queue_free()
	Global.reset_values()
