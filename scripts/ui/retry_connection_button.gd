extends Button


func _ready() -> void:
	_on_server_status_changed(Config.ServerStatus.NotChecked)
	Config.server_status_changed.connect(_on_server_status_changed)
	pressed.connect(_on_pressed)


func _on_server_status_changed(status: Config.ServerStatus) -> void:
	match status:
		Config.ServerStatus.Unreachable:
			visible = true
		Config.ServerStatus.Checking:
			pass
		Config.ServerStatus.NotChecked:
			Config.refresh_server_status()
		Config.ServerStatus.Reachable:
			visible = false


func _on_pressed() -> void:
	Config.refresh_server_status()
