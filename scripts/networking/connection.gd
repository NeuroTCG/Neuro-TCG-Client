extends Node
class_name Connection

var _server_url: String
var ws := WebSocketPeer.new()

signal connection_failed(url: String, error: String)


func try_connect(url: String) -> bool:
	print("Connecting to '%s'" % url)
	var error := ws.connect_to_url(url)
	if error != OK:
		print("WARNING: couldn't connect to '%s'" % url)
		return false
	return true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(
		Config.server_status == Config.ServerStatus.Reachable,
		"started a game without the server being reachable"
	)
	_server_url = Config.ws_server_base + "/game"

	if !try_connect(_server_url):
		print("ERROR: all connection attempts failed")
		connection_failed.emit(_server_url, "couldn't connect")
		process_mode = PROCESS_MODE_DISABLED


func wait_until_connection_opened() -> void:
	var timeout_timer := get_tree().create_timer(10)
	while ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().process_frame
		if timeout_timer.time_left == 0:
			print("ERROR: all connection attempts failed")
			connection_failed.emit(_server_url, "timeout")
			process_mode = PROCESS_MODE_DISABLED
			break


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
		print("Stopping networking")
		connection_failed.emit(_server_url, "connection closed")  # TODO: maybe make separate signal for this
		process_mode = PROCESS_MODE_DISABLED


func parse_msg() -> bool:
	var parsed := ws.get_packet().get_string_from_utf8()

	Global.network_manager.receive_command(parsed)

	return true
