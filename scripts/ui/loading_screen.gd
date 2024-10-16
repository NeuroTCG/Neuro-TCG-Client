extends Control
class_name LoadingScreen

var game_node := load("res://scenes/game/game.tscn")

var loading_text: String = "Loading...":
	set(new_text):
		$Label.text = new_text

var duration := 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.network_manager = NetworkManager.new()
	Global.add_child(Global.network_manager)
	Global.network_manager_ready.emit()
	Global.network_manager.match_found.connect(__on_match_found)
	Global.network_manager.disconnect.connect(__tmp_on_disconnect)
	Global.network_manager.client_info_accept.connect(__on_client_info_accept)
	Global.network_manager.authentication_valid.connect(__on_authentication_valid)
	Global.network_manager.start_initial_packet_sequence()


func __on_match_found(packet: MatchFoundPacket) -> void:
	loading_text = "Match found"
	var game = game_node.instantiate()
	get_parent().add_child(game)

	Global.player_field = game.get_node("PlayerField")
	Global.enemy_field = game.get_node("EnemyField")

	Global.ram_manager = game.get_tree().get_first_node_in_group("ram_manager")
	Global.ram_manager.reset_ram(packet.is_first_player)

	queue_free()


func __on_client_info_accept(_packet: ClientInfoAcceptPacket) -> void:
	loading_text = "Authenticating..."


func __on_authentication_valid(_packet: AuthenticationValidPacket) -> void:
	loading_text = "Waiting for opponent..."


func __tmp_on_disconnect(packet: DisconnectPacket) -> void:
	print("Disconnected with message %s" % packet.message)
