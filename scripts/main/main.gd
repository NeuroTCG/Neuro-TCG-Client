extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	User.client = Client.new() 
	add_child(User.client)
	await User.client.wait_until_connection_opened()
	User.client.ws.send_text("version,early development build")
	
	
	
