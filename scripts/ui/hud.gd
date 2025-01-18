extends CanvasLayer

@onready var pause_screen := $PauseScreen
@onready var shortcuts_label: Label = $ShortcutsLabel

@onready var notice := $Notice
@onready var notice_text: Label = %NoticeText
@onready var close_notice_button: Button = %CloseNoticeButton
@onready var end_turn_button: Button = $EndTurnButton

var main_menu := preload("res://scenes/ui/main_menu.tscn")


func _ready() -> void:
	Global.show_shortcuts.connect(_on_show_shortcuts)
	Global.hide_shortcuts.connect(_on_hide_shortcuts)
	Global.notice.connect(_on_notice)
	RenderOpponentAction.opponent_finished.connect(show_end_turn_button)
	VerifyClientAction.player_finished.connect(hide_end_turn_button)
	shortcuts_label.text = "   "

	if MatchManager.first_player:
		show_end_turn_button()
	else:
		hide_end_turn_button()

func _on_show_shortcuts(shortcuts: PackedStringArray) -> void:
	for shortcut in shortcuts:
		shortcuts_label.text += shortcut
	shortcuts_label.text.rstrip(",")


func _on_hide_shortcuts() -> void:
	shortcuts_label.text = "   "


func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		if pause_screen.visible:
			pause_screen.visible = false
		else:
			pause_screen.visible = true


func return_to_menu() -> void:
	get_parent().get_parent().add_child(main_menu.instantiate())
	get_parent().queue_free()


func _on_quit_button_pressed() -> void:
	return_to_menu()


func _on_notice(msg: String) -> void:
	notice.visible = true
	notice_text.text = msg
	await get_tree().create_timer(2.0).timeout
	notice.visible = false


func _on_close_notice_button_pressed() -> void:
	notice.visible = false

func hide_end_turn_button() -> void:
	end_turn_button.visible = false

func show_end_turn_button() -> void:
	end_turn_button.visible = true

func _on_end_turn_button_pressed() -> void:
	MatchManager.request_end_turn.emit()
