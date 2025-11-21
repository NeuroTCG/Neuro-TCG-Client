extends Node

@onready var status_label: Label = %UpdateStatusLabel
@onready var progress_bar: ProgressBar = %DownladProgressBar
@onready var http_request: HTTPRequest = $HTTPRequest

const VERSION_FILE_NAME := "user://version.txt"
const LATEST_RELEASE_URL := "https://api.github.com/repos/NeuroTCG/Neuro-TCG-Client/releases/latest"

var executable_extension := OS.get_executable_path().get_extension()
var normal_executable_name := (
	OS.get_executable_path().get_basename().trim_suffix(".tmp") + "." + executable_extension
)
var tmp_executable_name := OS.get_executable_path().get_basename() + ".tmp." + executable_extension

var new_version := ""
var current_version := "v0.0.0"

signal update_done


func _ready() -> void:
	await get_parent().ready

	if FileAccess.file_exists(VERSION_FILE_NAME):
		var version_file = FileAccess.open(VERSION_FILE_NAME, FileAccess.READ)
		current_version = version_file.get_as_text().strip_edges()
		version_file.close()

	if OS.has_feature("web") or OS.has_feature("editor"):
		print("running in editor or on web. Not performing updates")
		update_done.emit()
		return

	if executable_extension == "":
		print("No executable extension detected.")
		status_label.text = "We couldn't detect the game executable. Make sure it has the correct extension for your platform."
		return

	if OS.get_cmdline_args().count("--no-copy-back"):
		print("--no-copy-back specified. Not performing copy")
	elif OS.get_cmdline_args().count("--no-update"):
		# this program is running from the temporary binary
		await get_tree().create_timer(1).timeout  # wait for the parent process to exit and close the file

		print("--no-update argument specified. --no-copy-back not specified")
		print("copying '%s' to '%s'" % [OS.get_executable_path(), normal_executable_name])
		DirAccess.copy_absolute(OS.get_executable_path(), normal_executable_name)

		update_done.emit()

	else:
		# this program is running from the normal binary
		if FileAccess.file_exists(tmp_executable_name):
			print("Found old update file. Removing")
			DirAccess.remove_absolute(tmp_executable_name)

	print("Checking for newer version")
	status_label.text = "Checking for a newer version (Yours is %s)" % current_version
	progress_bar.value = 0
	http_request.request(LATEST_RELEASE_URL)

	var request = await http_request.request_completed
	var result = request[0] as HTTPRequest.Result
	var response_code = request[1] as HTTPClient.ResponseCode
	var _headers = request[2]
	var body = request[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		status_label.text = ("An error occured while checking for a new version: %s" % result)
		return

	if response_code != HTTPClient.RESPONSE_OK:
		status_label.text = (
			"An error occured while checking for a new version (%i): \n%s"
			% [response_code, body.get_string_from_utf8()]
		)
		return

	var latest_relesase_info = JSON.parse_string(body.get_string_from_utf8())

	new_version = latest_relesase_info["tag_name"]
	print("Current version is " + current_version)
	print("Newest version is " + new_version)

	if current_version == new_version:
		print("No need to update. Starting game")
		update_done.emit()
		return

	var new_executable_url := ""
	for asset in latest_relesase_info["assets"]:
		if asset["name"].ends_with(executable_extension):
			new_executable_url = asset["browser_download_url"]
			break
		else:
			print("Binary '%s' doesn't end with '%s'" % [asset["name"], executable_extension])

	if new_executable_url == "":
		status_label.text = (
			"No release binary with extension '%s' was found. Either your platform isn't supported or there was an error"
			% executable_extension
		)
		return

	# new_executable_url = "http://localhost:3000/game.x86_64"

	print("Downloading '%s'" % new_executable_url)
	status_label.text = "Downloading %s" % new_version
	http_request.request(new_executable_url)

	request = await http_request.request_completed
	result = request[0] as HTTPRequest.Result
	response_code = request[1] as HTTPClient.ResponseCode
	_headers = request[2]
	body = request[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		status_label.text = ("An error occured while downloading the new version: %s" % result)
		return

	if response_code != HTTPClient.RESPONSE_OK:
		status_label.text = (
			"An error occured while downloading the new version (%i): \n%s"
			% [response_code, body.get_string_from_utf8()]
		)
		return

	print("New version downloaded. Saving to %s" % tmp_executable_name)
	var file = FileAccess.open(tmp_executable_name, FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	FileAccess.set_unix_permissions(
		tmp_executable_name,
		(
			FileAccess.UNIX_READ_OWNER
			| FileAccess.UNIX_READ_GROUP
			| FileAccess.UNIX_READ_OTHER
			| FileAccess.UNIX_WRITE_OWNER
			| FileAccess.UNIX_EXECUTE_OWNER
			| FileAccess.UNIX_EXECUTE_GROUP
			| FileAccess.UNIX_EXECUTE_OTHER
		)
	)  # chmod 755

	var version_file = FileAccess.open(VERSION_FILE_NAME, FileAccess.WRITE)
	version_file.store_string(new_version)
	version_file.close()

	print("Starting downloaded binary")

	# the game doesn't start if we don't store the
	# process and if we close this process to early
	OS.create_process(tmp_executable_name, ["--no-update"])
	get_tree().quit()


func _process(_delta: float) -> void:
	progress_bar.value = (
		float(http_request.get_downloaded_bytes()) / float(http_request.get_body_size()) * 100
	)
