class_name CardState

var id: int
var health: int
var ability_was_used: bool
var phase: Card.TurnPhase
var shield: int
var sealed_turns_left: int


func _init(
	id_: int,
	health_: int,
	ability_was_used_: bool,
	phase_: int,
	shield_: int,
	sealed_turns_left_: int
) -> void:
	id = id_
	health = health_
	ability_was_used = ability_was_used_
	phase = phase_ as Card.TurnPhase
	shield = shield_
	sealed_turns_left = sealed_turns_left_


func to_dict() -> Dictionary:
	return {
		"id": id,
		"health": health,
		"ability_was_used": ability_was_used,
		"phase": phase,
		"shield": shield,
		"sealed_turns_left": sealed_turns_left,
	}


static func fromCardStats(id_: int, stats: CardStats) -> CardState:
	return CardState.new(id_, stats.max_hp, false, Card.TurnPhase.MoveOrAction, 0, 0)


# NOTE: no type because godot doesn't have a way to write nullable types
static func from_dict(d) -> CardState:
	if d == null:
		return null

	return CardState.new(
		d["id"], d["health"], d["ability_was_used"], d["phase"], d["shield"], d["sealed_turns_left"]
	)
