class_name CardActionArg

var arg_name: String
var arg_value: String

func _init(_arg_name, _arg_value):
	arg_name = _arg_name
	arg_value = _arg_value

static func from_dict(d: Dictionary):
	return CardActionArg.new(d["arg_name"], d["arg_value"])

func _to_string() -> String:
	return "CardActionArg: {%s:%s}" % [arg_name, arg_value]
