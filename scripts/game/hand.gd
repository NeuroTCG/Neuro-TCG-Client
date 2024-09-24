extends Node2D
class_name Hand

const CARD_LENGTH := 31 * 2 + 10

@onready var card_positions: Array = [$Pos1, $Pos2, $Pos3, $Pos4, $Pos5]
var cards: Array = []
# TODO: eliminate if possible
var selected_card = null
