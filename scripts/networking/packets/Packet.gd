class_name Packet

var type: String

func _init(type_: String):
	assert(type_ in PacketType.allTypes)
	type = type_

func to_dict() -> Dictionary:
	assert(false, "Abstract method 'to_dict' was called on Packet. Please override it.")
	return {}
