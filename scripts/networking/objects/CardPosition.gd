class_name CardPosition

var row: int
var column: int


func _init(row_: int, column_: int) -> void:
	assert(-1 <= row_ and row_ <= 1)
	if row_ == -1:
		assert(0 <= column_ and column_ <= Hand.MAX_HAND_SIZE - 1)
	elif row_ == 0:
		assert(0 <= column_ and column_ <= 3)
	elif row_ == 1:
		assert(0 <= column_ and column_ <= 2)
	row = row_
	column = column_


func to_array() -> Array[int]:
	return [row, column]


func _to_string():
	return "CardPosition: [%d, %d]" % [row, column]


static func from_array(d: Array) -> CardPosition:
	return CardPosition.new(d[0], d[1])
