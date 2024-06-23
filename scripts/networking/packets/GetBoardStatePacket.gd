extends Packet
class_name GetBoardStatePacket

var reason: String

class Reason:
    const state_conflict: String = "auth_invalid"
    const reconnect: String = "reconnect"
    const connect: String = "connect"
    const debug: String = "debug"

    static var allReasons = [state_conflict, reconnect, connect, debug]
func _init(reason_: String):
    super(PacketType.GetBoardState)
    reason = reason_

func to_dict() -> Dictionary:
    return {
        "type": type,
        "reason": reason
    }
    
static func from_dict(d: Dictionary):
    assert(d["reason"] in Reason.allReasons)
    return GetBoardStatePacket.new(d["reason"])
