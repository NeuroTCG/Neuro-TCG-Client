extends CanvasLayer

const DEFAULT_LABEL := "Login to Neuro TCG"
const AUTHENTICATING_LABEL := "Authenticating..."

var main_menu_template := preload("res://scenes/ui/main_menu.tscn")

@onready var StatusLabel := $Control/VBoxContainer/StatusLabel
@onready var AuthMethodsContainer := $Control/VBoxContainer/AuthMethodsContainer
@onready var URLText := $Control/VBoxContainer/URL
@onready var request := $HTTPRequest
@onready var AuthenticatingGroup = $Control/VBoxContainer/Authenticating
@onready var AfterCopyTimer = $AfterCopyTimer


func _save_token_and_load_main_menu(token: String):
	Auth.set_token_and_save(token)
	get_parent().add_child(main_menu_template.instantiate())
	queue_free()


func _auth_info_request_completed(_result, response_code, _headers, body):
	# set timeout and disconnect, we only want to connect once
	request.set_timeout(20)
	request.request_completed.disconnect(_auth_info_request_completed)

	var json = JSON.parse_string(body.get_string_from_utf8())
	if response_code != 200:
		print("Error contacting server")
		_toggle_authentication_methods(true)
		return null

	var user_login_url: String = json["user_login_url"]
	var poll_url: String = json["poll_url"]
	print("User login URL: ", user_login_url, " Poll URL: ", poll_url)
	URLText.text = user_login_url

	while true:
		request.request(poll_url, [], HTTPClient.METHOD_GET)
		var response = await request.request_completed
		var r_code: int = response[1]
		var r_body = response[3].get_string_from_utf8()
		if r_code == 200:
			print("Authenticated with token: ", r_body)
			_save_token_and_load_main_menu(r_body)
			break
		elif r_code == 408 || r_code == 504:
			print("Timeout while attempting to authenticate")
			continue
		else:
			_toggle_authentication_methods(true)
			return null


func _contact_server():
	await Config.wait_for_server_reachable()
	request.request_completed.connect(_auth_info_request_completed)
	var error = request.request(Config.http_server_base + "/auth/begin", [], HTTPClient.METHOD_POST)
	if error != OK:
		print("Error contacting server")
		return null


func _ready():
	Config.server_status_changed.connect(_on_server_status_changed)
	Config.refresh_server_status()
	Auth.load_token()
	if Auth.token != "":
		_save_token_and_load_main_menu(Auth.token)
		return

	_toggle_authentication_methods(true)
	AfterCopyTimer.timeout.connect(_reset_status_label_after_copy)


func _on_server_status_changed(status: Config.ServerStatus) -> void:
	match status:
		Config.ServerStatus.Unreachable:
			StatusLabel.text = "The server is not reachable. Check you network settings."
			AuthMethodsContainer.visible = false
		Config.ServerStatus.Checking:
			StatusLabel.text = "Checking for server connection..."
			AuthMethodsContainer.visible = false
		Config.ServerStatus.NotChecked:
			Config.refresh_server_status()
			AuthMethodsContainer.visible = false
		Config.ServerStatus.Reachable:
			StatusLabel.text = "Login to Neuro TCG"
			AuthMethodsContainer.visible = true


func _toggle_authentication_methods(enabled: bool):
	AuthMethodsContainer.visible = enabled
	URLText.visible = !enabled
	AuthenticatingGroup.visible = !enabled
	if enabled:
		StatusLabel.text = DEFAULT_LABEL
		AfterCopyTimer.stop()
	else:
		StatusLabel.text = AUTHENTICATING_LABEL


func _on_login_button_pressed() -> void:
	await _contact_server()
	_toggle_authentication_methods(false)


func _on_back_pressed() -> void:
	_toggle_authentication_methods(true)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(URLText.text)
	StatusLabel.text = "Copied to clipboard!"

	AfterCopyTimer.wait_time = 2.0
	AfterCopyTimer.one_shot = true
	AfterCopyTimer.start()


func _on_open_pressed() -> void:
	OS.shell_open(URLText.text)


func _reset_status_label_after_copy() -> void:
	StatusLabel.text = AUTHENTICATING_LABEL
