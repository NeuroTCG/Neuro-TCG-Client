extends PacketWithResponseId
class_name AuthenticationValidPacket

var has_running_game: bool
var you: UserInfo


func _init(response_id_: int, has_running_game_: bool, you_: UserInfo) -> void:
	super(PacketType.AuthenticationValid, response_id_)
	has_running_game = has_running_game_
	you = you_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	(
		dict
		. merge(
			{
				"has_running_game": has_running_game,
				"you": you.to_dict(),
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> AuthenticationValidPacket:
	return AuthenticationValidPacket.new(
		d["response_id"], d["has_running_game"], UserInfo.from_dict(d["you"])
	)
