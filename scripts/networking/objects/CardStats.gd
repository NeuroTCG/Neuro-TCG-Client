class_name CardStats

enum Tactic {
	REACH,
	NIMBLE,
}

enum CardType {
	DECK_MASTER,
	CREATURE,
	MAGIC,
	TRAP,
	TOKEN,
}

var name: String
var graphics: String
var max_hp: int
var base_atk: int
var cost: int
var tactics: Array[Tactic]
var card_type: CardType
var ability: Ability
var has_summoning_sickness: bool


func _init(
	_name: String,
	_graphics: String,
	_hp: int,
	_atk: int,
	_cost: int,
	_tactics: Array[Tactic],
	_card_type: CardType,
	_ability: Ability,
	_has_summoning_sickness: bool,
) -> void:
	name = _name
	max_hp = _hp
	base_atk = _atk
	cost = _cost
	graphics = _graphics
	tactics = _tactics
	card_type = _card_type
	ability = _ability
	has_summoning_sickness = _has_summoning_sickness


func to_dict() -> Dictionary:
	return {
		"name": name,
		"graphics": graphics,
		"max_hp": max_hp,
		"base_atk": base_atk,
		"summoning_cost": cost,
		"tactics": tactics,
		"card_type": card_type,
		"ability": ability.to_dict(),
		"has_summoning_sickness": has_summoning_sickness,
	}

static func from_dict(d: Dictionary) -> CardStats:
	return CardStats.new(
		d["name"],
		d["graphics"],
		d["max_hp"],
		d["base_atk"],
		d["summoning_cost"],
		CardStats.convert_tactics_to_enum(d["tactics"]),
		CardStats.CardType.get(d["card_type"]),
		Ability.from_dict(d["ability"]),
		d["has_summoning_sickness"]
	)

static func convert_tactics_to_enum(tactics: Array) -> Array[Tactic]:

	var new_array: Array[Tactic]
	for str_tactic in tactics:
		new_array.append(CardStats.Tactic.get(str_tactic))

	return new_array
