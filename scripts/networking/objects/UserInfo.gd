class_name UserInfo

var id: String


func _init(id_: String) -> void:
	id = id_


func to_dict() -> Dictionary:
	return {
		"id": id,
	}


static func from_dict(d: Dictionary) -> UserInfo:
	return UserInfo.new(d["id"])
