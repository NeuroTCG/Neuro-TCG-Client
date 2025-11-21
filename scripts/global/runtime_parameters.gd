extends Node

var parameters := {}
var flags: Array[String] = []


func _ready():
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	var i := 0
	while i < len(args):
		if args[i].begins_with("--"):
			assert(i + 1 < len(args), "Every commandline argument with -- needs a parameter")
			parameters[args[i].substr(2)] = args[i + 1]
			i += 2
		elif args[i].begins_with("-"):
			flags.append(args[i].substr(1))
			i += 1
		else:
			print("Unknown commandline argument '%s'. Ignoring" % args[i])
			i += 1

	if OS.has_feature("web"):
		var query_param = JSON.parse_string(
			JavaScriptBridge.eval("JSON.stringify([...new URL(window.location.href).searchParams])")
		)
		for arg in query_param:
			if arg[1] == "":
				flags.append(arg[0])
			else:
				parameters[arg[0]] = arg[1]

	print("Runtime flags", flags)
	print("Runtime parameters", parameters)
