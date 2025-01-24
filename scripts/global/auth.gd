class_name Auth

static var token := "Token not loaded"


static func save_token(new_token: String):
	var file = FileAccess.open("user://token.txt", FileAccess.WRITE)
	file.store_string(new_token)
	file.close()
	token = new_token


static func load_token() -> String:
	var file = FileAccess.open("user://token.txt", FileAccess.READ)
	if file:
		token = file.get_as_text()
		file.close()
		return token
	return ""


static func delete_token():
	if FileAccess.file_exists("user://token.txt"):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("token.txt")
