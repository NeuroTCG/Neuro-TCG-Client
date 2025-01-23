extends Control

var game_node := load("res://scenes/game/game.tscn")

@onready var confirm_button = $ColorRect/VBoxContainer/BottomRow/SelectButton
@onready var card_info_text = $ColorRect/VBoxContainer/MiddleRow/CardInfoText

var selected_id: int = -1
var card_ids: Array = []

func _ready() -> void:
	Global.network_manager.game_start.connect(_on_game_start)
	Global.network_manager.deck_master_selected.connect(_on_deck_master_selected)
	card_ids = CardStatsManager.get_deck_master_ids()
	selected_id = card_ids[0]
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

func _on_confirm_button_clicked() -> void:
	Global.network_manager.send_packet(DeckMasterRequestPacket.new(selected_id))

func _on_deck_master_selected(packet: DeckMasterSelectedPacket) -> void:
	if packet.is_you:
		if not packet.valid:
			assert(false, "deck master select failed.")
		else:
			confirm_button.disabled = true
			confirm_button.text = "CONFIRMED"
	else:
		print("opponent has selected their deck master.")


func _on_game_start(packet: GameStartPacket) -> void:
	var game = game_node.instantiate()
	get_parent().add_child(game)

	Global.player_field = game.get_node("PlayerField")
	Global.enemy_field = game.get_node("EnemyField")

	Global.ram_manager = game.get_tree().get_first_node_in_group("ram_manager")
	Global.ram_manager.reset_ram(packet.is_first_player)


func update_card_display():
	card_info_text.text = "Selected:\n%s" % [CardStatsManager.card_info_dict[card_ids[selected_id]]]
