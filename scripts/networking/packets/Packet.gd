class_name Packet

func to_dict() -> Dictionary:
	assert(false, "Abstract method 'to_dict' was called on Packet. Please override it.")
	return {}

static var __highest_packet_id = 0
static func get_next_response_id() -> int:
	__highest_packet_id += 1
	return __highest_packet_id
