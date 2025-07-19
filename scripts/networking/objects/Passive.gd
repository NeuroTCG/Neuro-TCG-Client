class_name Passive

enum PassiveEffectType {
	NONE,
	CARD_DISCOUNT,
	REACH_HP_THRESHOLD,
	ATTACK_AFTER_ABILITY,
	NOT_IMPLEMENTED,
	DRAW_ON_DESTRUCTION,
	BUFF_ADJACENT, #atk, hp
	CANNOT_ATTACK
}

var effect: PassiveEffectType
var values: Array


func _init(_effect: PassiveEffectType, _values: Array) -> void:
	effect = _effect
	values = _values


func to_dict() -> Dictionary:
	return {
		"effect": effect,
		"values": values,
	}


static func from_dict(d: Dictionary) -> Passive:
	return Passive.new(PassiveEffectType.get(d["effect"]), d["values"])
