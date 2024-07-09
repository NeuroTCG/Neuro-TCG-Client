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
	VerifyClientAction.attack.connect(__tmp_on_attack)
	VerifyClientAction.summon.connect(__tmp_on_summon)
	User.get_board_state_response.connect(__tmp_on_game_state_received)
	User.disconnect.connect(__tmp_on_disconnect)
	User.match_found.connect(_on_game_start, CONNECT_ONE_SHOT)
	User.start_initial_packet_sequence()
	

func __tmp_on_game_state_received(_packet: GetBoardStateResponsePacket):
	print("Game State received")

func __tmp_on_disconnect(packet: DisconnectPacket):
	print("Disconnected with message %s" % packet.message)

func _on_game_start(_packet: MatchFoundPacket) -> void:
	print("Requesting game state")
	User.send_packet(GetBoardStatePacket.new(GetBoardStatePacket.Reason.connect))
	print("Summoning at 1,2")
	User.send_packet(SummonRequestPacket.new(0, CardPosition.new(1, 2)))
	print("Summoning at 1,2 again")
	User.send_packet(SummonRequestPacket.new(0, CardPosition.new(1, 2)))
	print("Attacking 0,0 with 1,2")
	User.send_packet(AttackRequestPacket.new(CardPosition.new(0, 0), CardPosition.new(1, 2)))
