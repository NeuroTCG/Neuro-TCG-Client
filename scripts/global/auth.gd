extends Node

var token := ""
var user_info: UserInfo = null

const TOKEN_FILE := "user://token.txt"

var request = HTTPRequest.new()


func _ready() -> void:
	add_child(request)


func _refresh_user_info() -> bool:
	await Config.wait_for_server_reachable()
	request.request(Config.http_server_base + "/users/@me", ["Authorization: Bearer " + token], HTTPClient.METHOD_GET)
	var result = await request.request_completed
	if result[1] != 200:
		print("ERROR: failed to get user info for token")
		return false

	var body = JSON.parse_string(result[3].get_string_from_utf8())

	user_info = UserInfo.from_dict(body)
	print("Refreshed user info: %s" % [JSON.stringify(user_info.to_dict())])
	return true


func set_token_and_save(new_token: String):
	token = new_token
	if await _refresh_user_info():
		var file = FileAccess.open(TOKEN_FILE, FileAccess.WRITE)
		file.store_string(token)
		file.close()
	else:
		delete_user_info()


func load_token() -> void:
	var file = FileAccess.open(TOKEN_FILE, FileAccess.READ)
	if file:
		token = file.get_as_text()
		file.close()

	if !await _refresh_user_info():
		delete_user_info()


func delete_user_info():
	if FileAccess.file_exists(TOKEN_FILE):
		DirAccess.remove_absolute(TOKEN_FILE)

	token = ""
	user_info = null
