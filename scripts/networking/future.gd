class_name Future

signal resolved(data)

var is_resolved := false
var stored_data


func wait():
	if is_resolved:
		return stored_data
	else:
		return await self.resolved


func resolve(data):
	is_resolved = true
	stored_data = data
	resolved.emit(data)
