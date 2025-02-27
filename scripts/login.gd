extends CanvasLayer

const DEFAULT_LABEL := "Login to Neuro TCG"
const AUTHENTICATING_LABEL := "Authenticating..."

var main_menu_template := preload("res://scenes/ui/main_menu.tscn")

@onready var StatusLabel := $Control/VBoxContainer/StatusLabel
@onready var AuthMethodsContainer := $Control/VBoxContainer/AuthMethodsContainer
@onready var URLText := $Control/VBoxContainer/URL
@onready var AuthenticatingGroup = $Control/VBoxContainer/Authenticating

var request := HTTPRequest.new()


func _ready():
	Config.server_status_changed.connect(_on_server_status_changed)
	Config.refresh_server_status()
	await Auth.load_token()
	if Auth.token != "":
		_load_main_menu()
		return

	request.set_timeout(20)

	add_child(request)

	_toggle_authentication_methods(true)


func _load_main_menu():
	get_parent().add_child(main_menu_template.instantiate())
	queue_free()


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
	else:
		StatusLabel.text = AUTHENTICATING_LABEL


func _on_login_button_pressed() -> void:
	_toggle_authentication_methods(false)

	var urls = await Auth.get_login_and_poll_url()

	if urls == null:
		print("Error contacting server")
		_toggle_authentication_methods(true)

	URLText.text = urls[0]
	var token = await Auth.poll_for_token(urls[1])
	if token == null:
		_toggle_authentication_methods(true)
	else:
		print("Authenticated with token: ", token)
		await Auth.set_user_token_and_save(token)
		_load_main_menu()


func _on_back_pressed() -> void:
	_toggle_authentication_methods(true)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(URLText.text)
	StatusLabel.text = "Copied to clipboard!"

	get_tree().create_timer(2).timeout.connect(_reset_status_label_after_copy)


func _reset_status_label_after_copy() -> void:
	StatusLabel.text = AUTHENTICATING_LABEL


func _on_open_pressed() -> void:
	OS.shell_open(URLText.text)
