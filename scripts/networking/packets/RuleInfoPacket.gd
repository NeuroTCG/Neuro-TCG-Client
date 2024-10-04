extends Packet
class_name RuleInfoPacket

var card_id_mapping: Dictionary


func _init(card_id_mapping_: Dictionary) -> void:
	super(PacketType.RuleInfo)
	card_id_mapping = card_id_mapping_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"card_id_mapping": card_id_mapping,
	}


static func from_dict(d: Dictionary) -> RuleInfoPacket:
	var card_id_mapping_ := {}
	var map: Dictionary = d["card_id_mapping"]
	for i in map:
		card_id_mapping_[int(i)] = CardStats.from_dict(map[i])
	return RuleInfoPacket.new(card_id_mapping_)
