class_name CardState

var id: int
var health: int

func _init(id_: int, health_: int):
	id = id_
	health = health_

func to_dict() -> Dictionary:
	return {
		"id": id,
		"health": health,
	}

static func from_dict(d):
	if d == null:
		return null

	return CardState.new(d["id"], d["health"])
