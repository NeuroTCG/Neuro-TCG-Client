class_name CardStats

enum AttackRange {
	STANDARD,
	REACH,
}

enum CardType {
	DECK_MASTER,
	CREATURE,
	MAGIC,
	TRAP,
	TOKEN,
}

var graphics: String
var max_hp: int
var base_atk: int
var cost: int
var attack_range: AttackRange
var card_type: CardType
var ability: Ability
var has_summoning_sickness: bool


func _init(
	_graphics: String,
	_hp: int,
	_atk: int,
	_cost: int,
	_atk_range: AttackRange,
	_card_type: CardType,
	_ability: Ability,
	_has_summoning_sickness: bool,
) -> void:
	max_hp = _hp
	base_atk = _atk
	cost = _cost
	graphics = _graphics
	attack_range = _atk_range
	card_type = _card_type
	ability = _ability
	has_summoning_sickness = _has_summoning_sickness


func to_dict() -> Dictionary:
	return {
		"graphics": graphics,
		"max_hp": max_hp,
		"base_atk": base_atk,
		"summoning_cost": cost,
		"attack_range": attack_range,
		"card_type": card_type,
		"ability": ability.to_dict(),
		"has_summoning_sickness": has_summoning_sickness,
	}


static func from_dict(d: Dictionary) -> CardStats:
	return CardStats.new(
		d["graphics"],
		d["max_hp"],
		d["base_atk"],
		d["summoning_cost"],
		CardStats.AttackRange.get(d["attack_range"]),
		CardStats.CardType.get(d["card_type"]),
		Ability.from_dict(d["ability"]),
		d["has_summoning_sickness"]
	)
