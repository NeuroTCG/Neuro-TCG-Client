extends Node


signal update_passive(packet: PassiveUpdatePacket)
#Action Name Constants


func _init():
	update_passive.connect(_on_passive_update)

func _on_passive_update(packet: PassiveUpdatePacket):
	print("attempting to parse this passive!")
