extends Control

var settings := load("res://scenes/ui/settings.tscn")
var loading_screen := load("res://scenes/ui/loading_screen.tscn")
var login_screen := load("res://scenes/ui/login.tscn")

@onready var status_label: Label = $VBoxContainer2/BottomPanel/HBoxContainer/StatusLabel
@onready var play_button: Button = $"VBoxContainer2/BottomRow/VBoxContainer/Play-Button"


func _ready() -> void:
	Config.server_status_changed.connect(_on_server_status_changed)
	Config.refresh_server_status()


func _on_play_button_pressed() -> void:
	print("Starting game")
	get_parent().add_child(loading_screen.instantiate())
	queue_free()


func _on_settings_button_pressed() -> void:
	print("Entering settings")
	get_parent().add_child(settings.instantiate())
	queue_free()


func _on_quit_button_pressed() -> void:
	print("Quitting game")
	get_tree().quit()


func _on_profile_button_pressed() -> void:
	print("Viewing profile is not implemented")


func _on_logout_button_pressed() -> void:
	Auth.delete_user_info()
	get_parent().add_child(login_screen.instantiate())
	queue_free()


func _on_server_status_changed(status: Config.ServerStatus) -> void:
	match status:
		Config.ServerStatus.Unreachable:
			status_label.text = "The server is not reachable. Check you network settings."
			play_button.disabled = true
		Config.ServerStatus.Checking:
			status_label.text = "Checking for server connection..."
			play_button.disabled = true
		Config.ServerStatus.NotChecked:
			Config.refresh_server_status()
		Config.ServerStatus.Reachable:
			status_label.text = ""
			play_button.disabled = false
