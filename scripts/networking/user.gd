extends Node

var client: Client

class Command:
	func _init(name_: String, n_args: int):
		name = name_
		num_args = n_args
		
	var name: String
	var num_args: int

var commands: Array[Command] = [
	Command.new("version", 1),
	Command.new("summon", 3),
	Command.new("attack", 4),
]

func send_command(command: String, arguments: Array[String]):
	var command_exists = false
	for cmd in commands:
		if command == cmd.name:
			command_exists = true
			assert(len(arguments) == cmd.num_args, "Got %d arguments for command '%s'. Expected %d" % [len(arguments), command, cmd.num_args])
			break

	assert(command_exists, "Command '%s' does not exist" % command)

	client.ws.send_text(",".join([command] + arguments))
