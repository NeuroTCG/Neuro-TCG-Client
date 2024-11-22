extends Packet
class_name DebugEventPacket

var event: String


func _init(event_: String) -> void:
	super(PacketType.DebugEvent)
	event = event_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"event": event,
	}


static func from_dict(d: Dictionary) -> DebugEventPacket:
	return DebugEventPacket.new(d["event"])
