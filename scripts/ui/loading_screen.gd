extends Control
class_name LoadingScreen

var dm_select_node := load("res://scenes/game/deck_master_select.tscn")

var loading_text: String = "Loading...":
	set(new_text):
		$Label.text = new_text

var duration := 2.0

var player_user_info: UserInfo

var game_over_template = preload("res://scenes/ui/game_over.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.network_manager = NetworkManager.new()
	Global.add_child(Global.network_manager)
	Global.network_manager_ready.emit()
	Global.network_manager.match_found.connect(__on_match_found)
	Global.network_manager.disconnect.connect(_on_disconnect)
	Global.network_manager.client_info_accept.connect(__on_client_info_accept)
	Global.network_manager.authentication_valid.connect(__on_authentication_valid)
	Global.network_manager.connection.connection_failed.connect(__on_connection_failed)
	Global.network_manager.start_initial_packet_sequence()


func __on_match_found(packet: MatchFoundPacket) -> void:
	loading_text = "Match found"
	var dm_select = dm_select_node.instantiate()
	get_parent().add_child(dm_select)

	dm_select.player_user_info = player_user_info
	dm_select.opponent_user_info = packet.opponent

	queue_free()


func __on_client_info_accept(_packet: ClientInfoAcceptPacket) -> void:
	loading_text = "Authenticating..."


func __on_authentication_valid(packet: AuthenticationValidPacket) -> void:
	loading_text = "Waiting for opponent..."
	player_user_info = packet.you


func __on_connection_failed(url: String, error: String) -> void:
	loading_text = "Connecting to %s failed: %s" % [url, error]


func _on_disconnect(packet: DisconnectPacket) -> void:
	load_game_over("Disconnect packet received: %s (%s)" % [packet.message, packet.reason])


func load_game_over(message: String) -> void:
	var game_over = game_over_template.instantiate()

	game_over.get_node("VBoxContainer/WinLabel").text = message
	get_tree().root.add_child(game_over)

	queue_free()
	# stop any connections
	Global.network_manager.queue_free()
