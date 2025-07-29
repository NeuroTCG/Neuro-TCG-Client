extends PacketWithResponseId
class_name DrawCardRequestPacket


func _init(
	response_id_: int,
) -> void:
	super(PacketType.DrawCardRequest, response_id_)


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.merge({})
	return dict


static func from_dict(d: Dictionary) -> DrawCardRequestPacket:
	return (
		DrawCardRequestPacket
		. new(
			d["response_id"],
		)
	)
