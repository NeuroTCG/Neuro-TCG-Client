extends Node
class_name CardInfo

var graphics: Texture2D

var max_hp: int 
var base_atk: int 

func _init(p_graphics: Texture2D) -> void:
	graphics = p_graphics

func set_info(p_max_hp: int, p_base_atk: int) -> void:
	max_hp = p_max_hp
	base_atk = p_base_atk
