extends Control

const PLACEHOLDER_GRAPHIC = "res://assets/game/cards/template.png"

var game_node := load("res://scenes/game/game.tscn")
var player_user_info: UserInfo
var opponent_user_info: UserInfo

@onready var confirm_button = $Window/UI/BottomRow/SelectButton
@onready var selected_id_text = $Window/UI/MiddleRow/CardDisplay/IDText
@onready var card_info_name = $Window/UI/MiddleRow/CardInfo/CardName
@onready var card_info_desc = $Window/UI/MiddleRow/CardInfo/CardDescription
@onready var card_display_image = $Window/UI/MiddleRow/CardDisplay/CardImage
@onready var card_display_image_path = $Window/UI/MiddleRow/CardDisplay/CardImage/CardImagePath

var selected_id: int = -1
var card_ids: Array = []

func _ready() -> void:
	Global.network_manager.game_start.connect(_on_game_start)
	Global.network_manager.deck_master_selected.connect(_on_deck_master_selected)
	Global.network_manager.opponent_ready.connect(_on_opponent_ready)
	Global.network_manager.disconnect.connect(_on_disconnect)
	Global.network_manager.connection.connection_failed.connect(_on_connection_failed)
	card_ids = CardStatsManager.get_deck_master_ids()
	selected_id = 0
	update_card_display()


func _on_left_button_clicked() -> void:
	if (selected_id + 1 > card_ids.size() - 1):
		selected_id = 0
	else:
		selected_id += 1
	update_card_display()

func _on_right_button_clicked() -> void:
	if (selected_id - 1 < 0):
		selected_id = card_ids.size() - 1
	else:
		selected_id -= 1
	update_card_display()

func _on_opponent_ready() -> void:
	Global.network_manager.send_packet(OpponentReadyPacket.new())

func _on_confirm_button_clicked() -> void:
	Global.network_manager.send_packet(DeckMasterRequestPacket.new(card_ids[selected_id]))

func _on_deck_master_selected(packet: DeckMasterSelectedPacket) -> void:
	if packet.is_you:
		if not packet.valid:
			assert(false, "deck master select failed.")
		else:
			confirm_button.disabled = true
			confirm_button.text = "CONFIRMED"
	else:
		Global.network_manager.send_packet(OpponentReadyPacket.new())
		print("opponent has selected their deck master.")


func _on_game_start(packet: GameStartPacket) -> void:
	var game = game_node.instantiate()
	get_parent().add_child(game)

	Global.player_field = game.get_node("PlayerField")
	Global.enemy_field = game.get_node("EnemyField")

	(game.get_node("OpponentProfileDisplay") as ProfileDisplay).user_info = opponent_user_info
	(game.get_node("PlayerProfileDisplay") as ProfileDisplay).user_info = player_user_info

	Global.ram_manager = game.get_tree().get_first_node_in_group("ram_manager")
	Global.ram_manager.reset_ram(Global.network_manager.is_first_player)

	queue_free()


func update_card_display():
	var card_info = CardStatsManager.card_info_dict[card_ids[selected_id]]
	var stats = [card_info.max_hp, card_info.cost, card_info.base_atk, card_info.ability.cost]
	card_info_name.text = card_info.name
	card_info_desc.text = "Max HP: %s\nSummon Cost: %s\nAttack Power: %s\nAbility Cost: %s" % stats
	selected_id_text.text = "Selected ID: %s" % card_ids[selected_id]

	if (ResourceLoader.exists(card_info.graphics)):
		card_display_image.texture = load(card_info.graphics)
		card_display_image_path.text = ""
	else:
		card_display_image.texture = load(PLACEHOLDER_GRAPHIC)
		card_display_image_path.text = card_info.graphics

func _on_disconnect(packet: DisconnectPacket) -> void:
	load_game_over("Disconnect packet received: %s (%s)" % [packet.message, packet.reason])
func _on_connection_failed(url: String, error: String) -> void:
	load_game_over("Connection to %s failed: %s" % [url, error])


func load_game_over(message: String) -> void:
	var game_over = Global.game_over_template.instantiate()

	game_over.get_node("VBoxContainer/WinLabel").text = message
	get_tree().root.add_child(game_over)

	queue_free()

	# stop any connections
	Global.network_manager.queue_free()
	Global.reset_values()
