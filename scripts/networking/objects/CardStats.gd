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
var cost: int
var base_atk: int
var max_hp: int
var tactics: Array[Tactic]
var card_type: CardType
var ability: Ability
var passive: Passive


func _init(
	_name: String,
	_graphics: String,
	_cost: int,
	_atk: int,
	_hp: int,
	_tactics: Array[Tactic],
	_card_type: CardType,
	_ability: Ability,
	_passive: Passive
) -> void:
	name = _name
	graphics = _graphics
	cost = _cost
	base_atk = _atk
	max_hp = _hp
	tactics = _tactics
	card_type = _card_type
	ability = _ability
	passive = _passive

func to_dict() -> Dictionary:
	return {
		"name": name,
		"graphics": graphics,
		"cost": cost,
		"base_atk": base_atk,
		"max_hp": max_hp,
		"tactics": tactics,
		"card_type": card_type,
		"ability": ability.to_dict(),
		"passive": passive.to_dict(),
	}

static func from_dict(d: Dictionary) -> CardStats:
	return CardStats.new(
		d["name"],
		d["graphics"],
		d["summoning_cost"],
		d["base_atk"],
		d["max_hp"],
		CardStats.convert_tactics_to_enum(d["tactics"]),
		CardStats.CardType.get(d["card_type"]),
		Ability.from_dict(d["ability"]),
		Passive.from_dict(d["passive"]),
	)

static func convert_tactics_to_enum(tactics: Array) -> Array[Tactic]:
	var new_array: Array[Tactic]
	for str_tactic in tactics:
		new_array.append(CardStats.Tactic.get(str_tactic))

	return new_array
