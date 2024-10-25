extends Packet
class_name AuthenticatePacket

var username: String
var has_oauth: bool
var oauth_data: String


func _init(username_: String, has_oauth_: bool = false, oauth_data_: String = "") -> void:
	super(PacketType.Authenticate)
	username = username_
	has_oauth = has_oauth_
	oauth_data = oauth_data_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"username": username,
		"hasOAuth": has_oauth,
		"oAuthData": oauth_data,
	}


static func from_dict(d: Dictionary) -> AuthenticatePacket:
	return AuthenticatePacket.new(d["username"], d["hasOAuth"], d["oAuthData"])
