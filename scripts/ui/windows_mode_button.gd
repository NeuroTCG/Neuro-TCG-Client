extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_window_mode_selected)
	selected = SavedSettings.settings.window_mode

func _on_window_mode_selected(index):
	SavedSettings.set_window_mode(index)
	SavedSettings.settings.window_mode = index
