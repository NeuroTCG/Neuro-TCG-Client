extends Node
class_name Connection

var url := "ws://127.0.0.1:9933/game"
var ws := WebSocketPeer.new()


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	var error := ws.connect_to_url(url)
	if error != OK:
		print("ERROR: Cannot connect to url!")


func wait_until_connection_opened() -> void:
	var timeout_timer := get_tree().create_timer(10)
	while ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().process_frame
		if timeout_timer.time_left == 0:
			assert(false, "Connection timed out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	ws.poll()
	var state := ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while ws.get_available_packet_count():
			if parse_msg():
				pass
			else:
				print("ERROR cannot parse message!")
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code := ws.get_close_code()
		var reason := ws.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false)  # Stop processing.


func parse_msg() -> bool:
	var parsed := ws.get_packet().get_string_from_utf8()

	Global.network_manager.receive_command(parsed)

	return true
