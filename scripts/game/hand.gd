extends Node2D

const CARD_LENGTH := 111

@export var game: Node2D

@onready var card_positions: Array = [$Pos1, $Pos2, $Pos3, $Pos4, $Pos5]
var cards: Array = []

func _ready() -> void:
	# Set hand positions  
	for i in range(5):
		get_node("Pos" + str(i+1)).position.x = i * CARD_LENGTH 

func _process(delta) -> void:
	if Input.is_action_just_pressed("add_card"):
		add_card(1) 
	if Input.is_action_just_pressed("summon"):
		summon(0, [0, 0])

func add_card(id: int) -> void:
	if cards.size() >= 5:
		push_error("The hand can only store 5 cards!")
		return 
	
	var new_card = Card.create_card("test card", id, 0, 0, 0) 
	game.add_child(new_card)
	new_card.global_position = game.get_node("Deck").global_position
	new_card.flip_card()
	new_card.move_card(card_positions[cards.size()].global_position)
	cards.append(new_card)

func summon(hand_pos: int, board_pos: Array) -> void:
	# Convert board_pos to vector2 position. 
	# (Using a board static method) 
	# Board is currently not implemented.
	
	cards.pop_at(hand_pos).move_card(Vector2(350, 250)) 
	
	# Shift all cards right of summoned card
	for i in range(hand_pos, cards.size()):
			cards[i].move_card(card_positions[i].global_position)
	
	
	
