extends PacketWithResponseId
class_name AuthenticatePacket

var token: String


func _init(response_id_: int, token_: String) -> void:
	super(PacketType.Authenticate, response_id_)
	token = token_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"token": token,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> AuthenticatePacket:
	return AuthenticatePacket.new(d["response_id"], d["token"])
