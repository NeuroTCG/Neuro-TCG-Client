class_name GetBoardStateResponsePacket
extends PacketWithResponseId

var board: BoardState


func _init(response_id_: int, board_: BoardState) -> void:
	super(PacketType.GetBoardStateResponse, response_id_)
	board = board_


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	(
		dict
		. merge(
			{
				"board": board.to_dict(),
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> GetBoardStateResponsePacket:
	return GetBoardStateResponsePacket.new(d["response_id"], BoardState.from_dict(d["board"]))
