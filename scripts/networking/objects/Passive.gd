class_name Passive

enum PassiveEffectType {
	NONE,
	DRAW_ON_DESTRUCTION,
	BUFF_ADJACENT,
}

var effect: PassiveEffectType
var values: Array
var values_size: int

func _init(_effect: PassiveEffectType, _values: Array, _values_size: int) -> void:
	effect = _effect
	values = _values
	values_size = _values_size

func to_dict() -> Dictionary:
	return {
		"effect": effect,
		"values": values,
		"values_size": values_size,
	}

static func from_dict(d: Dictionary) -> Passive:
	return Passive.new(
		PassiveEffectType.get(d["effect"]), d["values"], d["valuesSize"]
	)
