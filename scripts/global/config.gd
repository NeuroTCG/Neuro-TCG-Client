extends Node

var http_server_base: String
var ws_server_base: String

var request := HTTPRequest.new()

#url to robotino's server
#var _server_template := "robotino.ch/neurotcg"

var _server_template := "127.0.0.1:9933"

enum ServerStatus {
	Checking,
	NotChecked,
	Reachable,
	Unreachable,
}

var _server_status := ServerStatus.NotChecked
var server_status := ServerStatus.NotChecked:
	set(value):
		_server_status = value
		server_status_changed.emit(value)
	get:
		return _server_status

signal server_status_changed(status: ServerStatus)


func _ready() -> void:
	add_child(request)
	request.timeout = 5
	refresh_server_status()


## this is an async function so make sure to await it
func wait_for_server_reachable():
	if server_status == ServerStatus.Reachable:
		return
	while (await server_status_changed) != ServerStatus.Reachable:
		pass


func refresh_server_status():
	if server_status == ServerStatus.Checking:
		print("WARN: tried refreshing the server status while a check was already running")
		return

	server_status = ServerStatus.Checking

	if RuntimeParameters.parameters.has("server-url"):
		_server_template = RuntimeParameters.parameters["server-url"]

	request.request("https://" + _server_template + "/fire")
	var result = await request.request_completed
	if result[1] == 200 && result[3].get_string_from_utf8() == "water":
		http_server_base = "https://" + _server_template
		ws_server_base = "wss://" + _server_template
		print("INFO: server is reachable on %s" % http_server_base)

		server_status = ServerStatus.Reachable
		return

	print("WARN: connection to %s failed. Trying http" % ("https://" + _server_template))

	request.request("http://" + _server_template + "/fire")
	result = await request.request_completed
	if result[1] == 200 && result[3].get_string_from_utf8() == "water":
		http_server_base = "http://" + _server_template
		ws_server_base = "ws://" + _server_template
		print("INFO: server is reachable on %s" % http_server_base)

		server_status = ServerStatus.Reachable
		return

	print(
		(
			"ERROR: http connection to %s failed. The server doesn't seem reachable"
			% ("http://" + _server_template)
		)
	)
	server_status = ServerStatus.Unreachable
