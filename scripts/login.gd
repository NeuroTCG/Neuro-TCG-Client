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
@onready var host := "http://localhost:9933"


func _save_token_and_load_main_menu(token: String):
	Auth.save_token(token)
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
		var r_body: String = response[3].get_string_from_utf8()
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


func _check_token_valid(token: String) -> bool:
	request.request(host + "/users/@me", ["Authorization: Bearer " + token], HTTPClient.METHOD_GET)
	# NOTE: awaiting because we need this to be blocking
	var result = await request.request_completed
	return result[1] == 200


func _contact_server():
	request.request_completed.connect(_auth_info_request_completed)
	var error = request.request(host + "/auth/begin", [], HTTPClient.METHOD_POST)
	if error != OK:
		print("Error contacting server")
		return null


func _ready():
	var token = Auth.load_token()
	if token != "" && await _check_token_valid(token):
		_save_token_and_load_main_menu(token)
		return

	_toggle_authentication_methods(true)
	AfterCopyTimer.timeout.connect(_reset_status_label_after_copy)


func _toggle_authentication_methods(enabled: bool):
	AuthMethodsContainer.visible = enabled
	URLText.visible = !enabled
	AuthenticatingGroup.visible = !enabled
	if enabled:
		StatusLabel.text = DEFAULT_LABEL
		AfterCopyTimer.stop()
	else:
		StatusLabel.text = AUTHENTICATING_LABEL


func _on_discord_button_pressed() -> void:
	_contact_server()
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
