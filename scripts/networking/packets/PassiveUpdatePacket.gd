class_name PassiveUpdatePacket
extends Packet

var updates: Array[CardActionList]


func _init(d: Dictionary):
	super(PacketType.PassiveUpdate)
	updates = []
	for u in d["updates"]:
		updates.append(CardActionList.from_dict(u))


static func from_dict(d: Dictionary) -> PassiveUpdatePacket:
	return PassiveUpdatePacket.new(d)
