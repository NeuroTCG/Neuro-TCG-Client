extends Node

var version = "early development build"

var main_menu_template = preload ("res://scenes/ui/main_menu.tscn")
var loading_screen_template = preload ("res://scenes/ui/loading_screen.tscn")
@export var music_file: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_menu_template.instantiate())
	AudioSystem.play_music(music_file)
	
	User.client = Client.new()
	add_child(User.client)
	await User.client.wait_until_connection_opened()
	User.get_board_state_response.connect(__tmp_on_game_state_received)
	User.disconnect.connect(__tmp_on_disconnect)
	User.start_initial_packet_sequence()
	

func __tmp_on_game_state_received(_packet: GetBoardStateResponsePacket):
	print("Game State received")

func __tmp_on_disconnect(packet: DisconnectPacket):
	print("Disconnected with message %s" % packet.message)
