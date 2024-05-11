extends Control
class_name LoadingScreen


var loading_text: String = "Loading...": 
	set(new_text): 
		$Label.text = new_text
	
var duration: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(duration).timeout
	queue_free()
	
