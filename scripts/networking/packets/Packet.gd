class_name Packet

var type: String

func _init(type_: String):
	assert(type_ in PacketType.allTypes)
	type = type_

func to_dict() -> Dictionary:
	assert(false, "Abstract method 'to_dict' was called on Packet. Please override it.")
	return {}

func get_response_id() -> int:
	return -1

static var __highest_packet_id = 0
static func get_next_response_id() -> int:
	__highest_packet_id += 1
	return __highest_packet_id
