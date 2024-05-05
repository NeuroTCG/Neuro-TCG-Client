extends TextureButton

var clickHandler: ButtonClickHandler

func _ready() -> void:
	pressed.connect(_on_pressed) # You can also do this directly from editor. 

func _on_pressed():
	# clickHandler.onClick(0)
	print("Quitting game")
	get_tree().quit()
