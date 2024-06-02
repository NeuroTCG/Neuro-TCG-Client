class_name FullCardState

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

static func from_dict(d: Dictionary):
	return FullCardState.new(d["id"], d["health"])
