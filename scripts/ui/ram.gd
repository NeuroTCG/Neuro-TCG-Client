extends Node2D

@export var enemy := false

@onready var progress_bar = $TextureProgressBar
@onready var label = $Label

var maxValue := 1


# Called when the node enters the scene tree for the first time.
func _ready():
	if enemy:
		Global.enemy_ram_changed.connect(_on_ram_changed)
		Global.update_enemy_max_ram.connect(_on_update_max_ram)
	else:
		Global.player_ram_changed.connect(_on_ram_changed)
		Global.update_max_ram.connect(_on_update_max_ram)


func _update_text():
	label.text = "RAM: %d/%d" % [progress_bar.value, maxValue]


func _on_ram_changed(value: int):
	progress_bar.value = value
	_update_text()


func _on_update_max_ram(value: int):
	maxValue = value
	_update_text()
