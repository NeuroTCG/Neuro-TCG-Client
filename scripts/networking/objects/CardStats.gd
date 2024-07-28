class_name CardStats

var max_hp: int
var base_atk: int
var summoning_cost: int

func _init(max_hp_: int, base_atk_:int, summoning_cost_: int):
	max_hp = max_hp_
	base_atk = base_atk_
	summoning_cost = summoning_cost_

func to_dict() -> Dictionary:
	return {
		"max_hp": max_hp,
		"base_atk": base_atk,
		"summoning_cost": summoning_cost,
	}

static func from_dict(d: Dictionary):
	return CardStats.new(d["max_hp"], d["base_atk"], d["summoning_cost"])
