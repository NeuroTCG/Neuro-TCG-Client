extends Packet
class_name GameOverPacket

var you_are_winner: bool


func _init(you_are_winner_: bool):
	super(PacketType.GameOver)
	you_are_winner = you_are_winner_


func to_dict() -> Dictionary:
	return {
		"type": type,
		"you_are_winner": you_are_winner,
	}


static func from_dict(d: Dictionary):
	return GameOverPacket.new(d["you_are_winner"])
