extends Node

var user_info: UserInfo = null
var token := ""
var _user_token := ""
var _development_token := ""

const TOKEN_FILE := "user://token.txt"

const DEFAULT_REQUEST_TIMEOUT = 5

var request = HTTPRequest.new()

var dev_username := ""


func _ready() -> void:
	request.timeout = DEFAULT_REQUEST_TIMEOUT
	add_child(request)

	var args = OS.get_cmdline_args()
	for i in range(len(args)):
		if args[i] == "--dev-username":
			dev_username = args[i + 1]
			print("INFO: development username was set by commandline: %s" % dev_username)
			break


## returns (user_login_url, poll_url) or null on error
func get_login_and_poll_url():
	await Config.wait_for_server_reachable()
	var error = request.request(Config.http_server_base + "/auth/begin", [], HTTPClient.METHOD_POST)
	if error != OK:
		print("ERROR: failed to start auth session")
		print(error)
		return null

	var result = await request.request_completed
	var response_code: int = result[1]
	var body: PackedByteArray = result[3]

	if response_code != 200:
		print("ERROR: /auth/begin returned code %d" % response_code)
		return null

	var json = JSON.parse_string(body.get_string_from_utf8())

	var user_login_url: String = json["user_login_url"]
	var poll_url: String = json["poll_url"]
	print("User login URL: ", user_login_url, " Poll URL: ", poll_url)
	return [user_login_url, poll_url]


func poll_for_token(poll_url: String, headers: Array = []):
	request.timeout = 20
	var new_token = null
	print("Auth polling on %s" % poll_url)
	while true:
		request.request(poll_url, headers, HTTPClient.METHOD_GET)
		var response = await request.request_completed
		var r_code: int = response[1]
		var r_body = response[3].get_string_from_utf8()
		if r_code == 200:
			print("INFO: Auth polling finished")
			new_token = r_body
			break
		elif r_code == 408 || r_code == 504:
			print("INFO: Timeout while attempting to authenticate")
			continue
		else:
			print("ERROR: Auth polling returned code %d" % r_code)
			new_token = null
			break

	request.timeout = DEFAULT_REQUEST_TIMEOUT
	return new_token


func _refresh_user_info() -> bool:
	await Config.wait_for_server_reachable()
	request.request(
		Config.http_server_base + "/users/@me",
		["Authorization: Bearer " + token],
		HTTPClient.METHOD_GET
	)
	var result = await request.request_completed
	if result[1] != 200:
		print("ERROR: failed to get user info for token")
		return false

	var body = JSON.parse_string(result[3].get_string_from_utf8())

	user_info = UserInfo.from_dict(body)
	print("INFO: Refreshed user info: %s" % [JSON.stringify(user_info.to_dict())])
	return true


func set_user_token_and_save(new_token: String):
	_user_token = new_token
	token = _user_token
	if await _refresh_user_info():
		var file = FileAccess.open(TOKEN_FILE, FileAccess.WRITE)
		file.store_string(_user_token)
		file.close()

		if dev_username != "":
			print("INFO: Upgrading to development user")

			if not await _upgrade_to_development_user():
				assert(false, "Upgrading to a development account failed")

	else:
		delete_user_info()


func _upgrade_to_development_user() -> bool:
	if dev_username == "":
		return false

	var urls = await get_login_and_poll_url()
	if urls == null:
		print("ERROR: dev upgrade failed to start auth session")
		return false

	var correlation_id = urls[0].split("=")[1]
	var headers = ["Authorization: Bearer " + _user_token]
	request.request(urls[0], headers)  # simulate the user opening the page
	var r_result = await request.request_completed
	if r_result[1] != 200:
		print("ERROR: dev upgrade login url returned code %d" % r_result[1])
		return false

	# TODO: don't hardcode this
	var provider_redirect_url = (
		Config.http_server_base
		+ (
			"/auth/providers/__development/begin?correlationId=%s&devUserId=%s"
			% [correlation_id, dev_username]
		)
	)
	request.request(provider_redirect_url, headers)
	r_result = await request.request_completed
	if r_result[1] != 200:
		print("ERROR: dev upgrade provider redirect returned code %d" % r_result[1])
		return false

	var new_token = await poll_for_token(urls[1], headers)
	if new_token == null:
		print("ERROR: dev upgrade failed to get token")
		return false

	_set_development_token(new_token)
	return true


func _set_development_token(new_token: String):
	_development_token = new_token
	token = _development_token
	if not await _refresh_user_info():
		_development_token = ""
		token = _user_token


func load_token() -> void:
	var file = FileAccess.open(TOKEN_FILE, FileAccess.READ)
	if file:
		_user_token = file.get_as_text()
		token = _user_token
		file.close()

	if await _refresh_user_info():
		if dev_username != "":
			print("INFO: Upgrading to development user")

			if not await _upgrade_to_development_user():
				assert(false, "Upgrading to a development account failed")
	else:
		delete_user_info()


func delete_user_info():
	if FileAccess.file_exists(TOKEN_FILE):
		DirAccess.remove_absolute(TOKEN_FILE)

	_user_token = ""
	_development_token = ""
	token = ""
	user_info = null
