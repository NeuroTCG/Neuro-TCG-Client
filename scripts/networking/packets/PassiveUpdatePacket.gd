class_name PassiveUpdatePacket
extends Packet

var updates: Array[CardActionList]


func _init(d: Dictionary):
	super(PacketType.PassiveUpdate)
	var update_array = d["updates"] as Array[Dictionary]
	for u in update_array:
		print(u)


static func from_dict(d: Dictionary) -> PassiveUpdatePacket:
	return PassiveUpdatePacket.new(d)
