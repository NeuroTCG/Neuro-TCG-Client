extends Node
class_name CardInfo

enum AttackRange {
	STANDARD,
	REACH 
}

var graphics: Texture2D

var max_hp: int
var base_atk: int   
var cost: int 
var attack_range: AttackRange

func _init(_graphics: Texture2D, _hp, _atk, _cost, _atk_range) -> void:
	max_hp = _hp 
	base_atk = _atk 
	cost = _cost
	graphics = _graphics
	attack_range = _atk_range

func set_info(p_max_hp: int, p_base_atk: int) -> void:
	max_hp = p_max_hp
	base_atk = p_base_atk
