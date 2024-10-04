class_name GetBoardStateResponsePacket
extends Packet

var board: BoardState


func _init(board_: BoardState) -> void:
	super(PacketType.GetBoardStateResponse)
	board = board_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"board": board.to_dict(),
	}


static func from_dict(d: Dictionary) -> GetBoardStateResponsePacket:
	return GetBoardStateResponsePacket.new(BoardState.from_dict(d["board"]))
