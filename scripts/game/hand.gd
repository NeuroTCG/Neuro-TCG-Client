extends Node2D
class_name Hand

const CARD_LENGTH := 31 * 2 + 10

const MAX_HAND_SIZE := 5

@onready var card_positions: Array[Marker2D] = [$Pos1, $Pos2, $Pos3, $Pos4, $Pos5]
var cards: Array[Card] = []

var selected_card: Card = null


func get_card_pos(card: Card) -> int:
	return cards.find(card)


# TODO: Abstract function: implement add_card() when extending.
func add_card(id: int):
	pass
