extends Control

class_name ProfileDisplay

@onready var userID_field := $Panel/VBoxContainer/UserID

var _user_info: UserInfo
var user_info: UserInfo:
	set(value):
		_user_info = value
		userID_field.text = "User ID: %s" % _user_info.id
	get:
		return _user_info
