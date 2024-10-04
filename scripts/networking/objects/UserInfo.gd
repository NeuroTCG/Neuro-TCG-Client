class_name UserInfo

var username: String
var region: String


func _init(username_: String, region_: String) -> void:
	username = username_
	region = region_


func to_dict() -> Dictionary:
	return {
		"username": username,
		"region": region,
	}


static func from_dict(d: Dictionary) -> UserInfo:
	return UserInfo.new(d["username"], d["region"])
