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
	print("Requesting game state")
	User.send_packet_expecting_type(
		GetBoardStatePacket.new(GetBoardStatePacket.Reason.connect),
		PacketType.GetBoardStateResponse,
		func(packet: GetBoardStatePacket.Response) -> bool:
			print("Received game state")
			print(packet.board.cards)
			# TODO: store it somewhere smart
			return true
	)

	print("Summoning at 1,2")
	User.send_packet_expecting_type(
		SummonPacket.new(0, CardPosition.new(1, 2)),
		PacketType.SummonResponse,
		func(packet: SummonPacket.Response) -> bool:
			if (packet.valid):
				print("Summon successfull. Card has %d hp." % packet.new_card.health)
			else:
				print("Summon failed")
			return true
	)
	
	print("Summoning at 1,2 again")
	User.send_packet_expecting_type(
		SummonPacket.new(0, CardPosition.new(1, 2)),
		PacketType.SummonResponse,
		func(packet: SummonPacket.Response) -> bool:
			if (packet.valid):
				print("Summon successfull. Card has %d hp." % packet.new_card.health)
			else:
				print("Summon failed")
			return true
	)
	print("Attacking 0,0 with 1,2")
	User.send_packet_expecting_type(
		AttackPacket.new(CardPosition.new(0, 0), CardPosition.new(1, 2)),
		PacketType.AttackResponse,
		func(packet: AttackPacket.Response) -> bool:
			if (packet.valid):
				print("Attack successfull. Attacked card now has %d hp." % packet.target_card.health)
			else:
				print("Attack failed")
			return true
	)
	