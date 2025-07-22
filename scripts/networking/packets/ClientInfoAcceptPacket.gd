extends PacketWithResponseId
class_name ClientInfoAcceptPacket


func _init(
	response_id_: int,
) -> void:
	super(PacketType.ClientInfoAccept, response_id_)


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.merge({})
	return dict


static func from_dict(d: Dictionary) -> ClientInfoAcceptPacket:
	return (
		ClientInfoAcceptPacket
		. new(
			d["response_id"],
		)
	)
