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
	User.on_game_start.connect(_on_game_start, CONNECT_ONE_SHOT)
	User.start_initial_packet_sequence()

func _on_game_start() -> void:
	print("Summoning at 1,2")
	User.send_packet_with_response_callback(
		SummonPacket.new(0, CardPosition.new(1, 2)),
		func(packet: Packet):
			match packet.type:
				PacketType.SummonResponse:
					var s_packet=packet as SummonPacket.Response
					if (s_packet.valid):
						print("Summon successfull. Card has %d hp." % s_packet.new_card.health)
					else:
						print("Summon failed")
				var type:
					print("Unexpected packet type '%s'" % type)
	)
	
	print("Summoning at 1,2 again")
	User.send_packet_with_response_callback(
		SummonPacket.new(0, CardPosition.new(1, 2)),
		func(packet: Packet):
			match packet.type:
				PacketType.SummonResponse:
					var s_packet=packet as SummonPacket.Response
					if (s_packet.valid):
						print("Summon successfull. Card has %d hp." % s_packet.new_card.health)
					else:
						print("Summon failed")
				var type:
					print("Unexpected packet type '%s'" % type)
	)
	print("Attacking 0,0 with 1,2")
	User.send_packet_with_response_callback(
		AttackPacket.new(CardPosition.new(0,0), CardPosition.new(1, 2)),
		func(packet: Packet):
			match packet.type:
				PacketType.AttackResponse:
					var s_packet=packet as AttackPacket.Response
					if (s_packet.valid):
						print("Attack successfull. Attacked card now has %d hp." % s_packet.target_card.health)
					else:
						print("Attack failed")
				var type:
					print("Unexpected packet type '%s'" % type)
	)
