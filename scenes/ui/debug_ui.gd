extends Panel

const DEBUG_EVENTS = ["save", "load"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pos_y = 0
	for event in DEBUG_EVENTS:
		var button := Button.new()
		button.connect(
			"pressed", func(): Global.network_manager.send_packet(DebugEventPacket.new(event))
		)

		button.text = event
		button.position = Vector2(0, pos_y) 
		button.mouse_filter = Control.MOUSE_FILTER_PASS

		pos_y += button.size.y + 4

		add_child(button)
		print("debug event button '" + event + "' added")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
