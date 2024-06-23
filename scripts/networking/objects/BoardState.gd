class_name BoardState

var cards: Array # really Array[Array[Array[CardState|null]]], but godot doesn't like that
var traps: Array

func _init(cards_: Array, traps_: Array):
	cards = cards_
	traps = traps_

func to_dict() -> Dictionary:
	var lcards = []
	for player in cards:
		lcards.append([])
		for row in player:
			for card in row:
				lcards[- 1].append(card.to_dict())

	assert(traps == [[null, null],[null, null]],"Traps aren't implemented yet.")

	return {
		"cards": lcards,
		"traps": traps,
	}

static func from_dict(d: Dictionary):
	var lcards = []
	for player in d["cards"]:
		lcards.append([])
		for row in player:
			lcards[- 1].append([])
			for card in row:
				if (card == null):
					lcards[- 1][ - 1].append(null)
				else:
					lcards[- 1][ - 1].append(CardState.from_dict(card))

	assert(d["traps"] == [[null, null],[null, null]],"Traps aren't implemented yet.")
	return BoardState.new(lcards, d["traps"])