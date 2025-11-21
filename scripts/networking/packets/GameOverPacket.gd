extends Packet
class_name GameOverPacket

var you_are_winner: bool


func _init(you_are_winner_: bool):
	super(PacketType.GameOver)
	you_are_winner = you_are_winner_


func to_dict() -> Dictionary:
	var dict = super.to_dict()
	(
		dict
		. merge(
			{
				"you_are_winner": you_are_winner,
			}
		)
	)
	return dict


static func from_dict(d: Dictionary):
	return GameOverPacket.new(d["you_are_winner"])
