extends Node2D

@export var enemy := false

@onready var progress_bar = $TextureProgressBar
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	if enemy:
		Global.update_enemy_ram.connect(_on_update_ram)
	else:
		Global.update_ram.connect(_on_update_ram)


func _on_update_ram(value: int):
	progress_bar.value = value 
	label.text = "RAM: %d/10" % value
