class_name Packet

var type: String


func _init(type_: String) -> void:
	assert(type_ in PacketType.allTypes)
	type = type_


func to_dict() -> Dictionary:
	return {"type": type}


static var last_response_id: int = 0


static func next_response_id() -> int:
	var tmp = last_response_id
	last_response_id += 1
	return tmp
