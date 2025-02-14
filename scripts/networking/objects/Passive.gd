class_name Passive

enum PassiveEffectType {
	NONE,
	DRAW_ON_DESTRUCTION,
	BUFF_ADJACENT,
}

var effect: PassiveEffectType
var valueX: int
var valueY: int


func _init(_effect: PassiveEffectType, _valueX: int, _valueY: int) -> void:
	effect = _effect
	valueX = _valueX
	valueY = _valueY

func to_dict() -> Dictionary:
	return {
		"effect": effect,
		"valueX": valueX,
		"valueY": valueY,
	}

static func from_dict(d: Dictionary) -> Passive:
	return Passive.new(
		PassiveEffectType.get(d["effect"]), d["valueX"], d["valueY"]
	)
