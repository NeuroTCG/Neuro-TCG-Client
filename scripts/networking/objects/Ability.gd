class_name Ability

enum AbilityEffect {
	NONE,
	ADD_HP,
	SEAL,
	ATTACK,
}

enum AbilityRange {
	NONE,
	ALLY_FIELD, 
	ENEMY_FIELD, 
	ALLY_CARD,
	ENEMY_CARD, 
	ENEMY_ROW, 
	PLAYER_DECK
}

var effect: AbilityEffect 
var value: int
var range: AbilityRange
var cost: int

func _init(_effect: AbilityEffect, _value: int, _range: AbilityRange, _cost: int) -> void:
	effect = _effect
	value = _value
	range = _range
	cost = _cost

func to_dict() -> Dictionary:
	return {
		"effect": effect,
		"value": value,
		"range": range, 
		"cost": cost, 
	}

static func from_dict(d: Dictionary):
	return Ability.new(
		AbilityEffect.get(d["effect"]),
		d["value"],
		AbilityRange.get(d["range"]),
		d["cost"]
	)
	
	
	
	
