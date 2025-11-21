extends HSlider

@export var bus_name := "music"

@onready var bus_index := AudioServer.get_bus_index(bus_name)


func _ready() -> void:
	value_changed.connect(_on_value_changed)

	if bus_name == "music":
		value = SavedSettings.settings.music_volume
	elif bus_name == "soundfx":
		value = SavedSettings.settings.sfx_volume


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
	if bus_name == "music":
		SavedSettings.settings.music_volume = new_value
	elif bus_name == "soundfx":
		SavedSettings.settings.sfx_volume = new_value
