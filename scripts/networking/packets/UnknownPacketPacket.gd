extends Packet
class_name UnknownPacketPacket

var message: String


func _init(message_: String) -> void:
	super(PacketType.UnknownPacket)
	message = message_


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	(
		dict
		. merge(
			{
				"message": message,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary) -> UnknownPacketPacket:
	return UnknownPacketPacket.new(d["message"])
