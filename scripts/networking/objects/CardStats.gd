class_name CardStats

var max_hp: int
var base_atk: int

func _init(max_hp_: int, base_atk_:int):
	max_hp = max_hp_
	base_atk = base_atk_

func to_dict() -> Dictionary:
	return {
		"max_hp": max_hp,
		"base_atk": base_atk,
	}

static func from_dict(d: Dictionary):
	return CardStats.new(d["max_hp"], d["base_atk"])
