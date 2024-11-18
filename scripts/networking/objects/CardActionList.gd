class_name CardActionList

var card: CardData
var actions: Array[CardAction]

func _init(_card: CardData, _actions: Array[CardAction]):
	card = _card;
	actions = _actions;

static func from_dict(d: Dictionary) -> CardActionList:

	var actions_array: Array[CardAction] = [];
	for a in d["actions"]:
		actions_array.append(CardAction.from_dict(a));
	return CardActionList.new(CardData.from_dict(d["card"]), actions_array)

func _to_string() -> String:
	return "CardActionList for %s containing %d actions." % [card, actions.size()]
