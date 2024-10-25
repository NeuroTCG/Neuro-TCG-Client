extends Packet
class_name AuthenticationValidPacket

var has_running_game: bool
var you: UserInfo
var has_new_tokens: bool
var new_access_token: String
var new_refresh_token: String


func _init(has_running_game_: bool, you_: UserInfo, has_new_tokens_: bool = false, new_access_token_: String = "", new_refresh_token_: String = "") -> void:
	super(PacketType.AuthenticationValid)
	has_running_game = has_running_game_
	you = you_
	has_new_tokens = has_new_tokens_
	new_access_token = new_access_token_
	new_refresh_token = new_refresh_token_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"has_running_game": has_running_game,
		"you": you.to_dict(),
		"hasNewTokens": has_new_tokens,
		"newAccessToken": new_access_token,
		"newRefreshToken": new_refresh_token,
	}


static func from_dict(d: Dictionary) -> AuthenticationValidPacket:
	return AuthenticationValidPacket.new(d["has_running_game"], UserInfo.from_dict(d["you"]), d["hasNewTokens"], d["newAccessToken"], d["newRefreshToken"])
