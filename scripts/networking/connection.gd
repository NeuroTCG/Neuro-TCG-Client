extends Node
class_name Connection

var server_url := "wss://robotino.ch/neurotcg/game"
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
	var args = OS.get_cmdline_args()
	for i in range(len(args)):
		if args[i] == "--server-url":
			server_url = args[i + 1]
			print("INFO: server url was overridden by commandline argument: %s" % server_url)
			break

	# set by the export template
	if OS.has_feature("web"):
		var query_param = JavaScriptBridge.eval(
			"new URL(window.location.href).searchParams.get('server-url')"
		)
		if query_param != null:
			server_url = query_param
			print("INFO: server url was overridden by query parameter: %s" % server_url)

	if !try_connect(server_url):
		print("ERROR: all connection attempts failed")
		connection_failed.emit(server_url, "couldn't connect")
		process_mode = PROCESS_MODE_DISABLED


func wait_until_connection_opened() -> void:
	var timeout_timer := get_tree().create_timer(10)
	while ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().process_frame
		if timeout_timer.time_left == 0:
			print("ERROR: all connection attempts failed")
			connection_failed.emit(server_url, "timeout")
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
		connection_failed.emit(server_url, "connection closed")  # TODO: maybe make separate signal for this
		process_mode = PROCESS_MODE_DISABLED


func parse_msg() -> bool:
	var parsed := ws.get_packet().get_string_from_utf8()

	Global.network_manager.receive_command(parsed)

	return true
