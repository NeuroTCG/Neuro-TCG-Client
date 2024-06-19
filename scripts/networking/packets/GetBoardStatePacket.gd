extends Packet
class_name GetBoardStatePacket

var response_id: int
var reason: String

class Reason:
    const state_conflict: String = "auth_invalid"
    const reconnect: String = "reconnect"
    const connect: String = "connect"
    const debug: String = "debug"

    static var allReasons = [state_conflict, reconnect, connect, debug]

class Response:
    extends Packet

    var response_id: int
    var board: GameState

    func _init(board_: GameState, response_id_: int=Packet.get_next_response_id()):
        super(PacketType.GetBoardStateResponse)
        response_id = response_id_
        board = board_

    func to_dict() -> Dictionary:
        return {
            "type": type,
            "response_id": response_id,
            "board": board.to_dict(),
        }

    func get_response_id() -> int:
        return response_id

    static func from_dict(d: Dictionary):
        return GetBoardStatePacket.Response.new(GameState.from_dict(d["board"]), d["response_id"])

func _init(reason_: String, response_id_: int=Packet.get_next_response_id()):
    super(PacketType.GetBoardState)
    response_id = response_id_
    reason = reason_

func to_dict() -> Dictionary:
    return {
        "type": type,
        "response_id": response_id,
        "reason": reason
    }

func get_response_id() -> int:
    return response_id
    
static func from_dict(d: Dictionary):
    assert(d["reason"] in Reason.allReasons)
    return GetBoardStatePacket.new(d["reason"], d["response_id"])
