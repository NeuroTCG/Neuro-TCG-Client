class_name CardPosition

var row: int
var column: int


func _init(row_: int, column_: int) -> void:
	assert(0 <= row_ and row_ <= 1)
	if row == 0:
		assert(0 <= column_ and column_ <= 3)
	elif row == 1:
		assert(0 <= column_ and column_ <= 2)
	row = row_
	column = column_


func to_array() -> Array[int]:
	return [row, column]


func _to_string():
	return "CardPosition: [%d, %d]" % [row, column]


static func from_array(d: Array) -> CardPosition:
	return CardPosition.new(d[0], d[1])
