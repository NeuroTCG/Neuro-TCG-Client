extends Button
class_name ButtonClickHandler

func onClick(action: int):
	prints("onClick function called with action", action)
	if action == 0:
		print("default string")
