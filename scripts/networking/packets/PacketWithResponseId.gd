class_name PacketWithResponseId
extends Packet

var response_id: int


func _init(type_: String, response_id_: int) -> void:
	super(type_)
	response_id = response_id_


func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.merge({"response_id": response_id})
	return dict
