extends Node

var score = 0
var combo = 0
var max_combo = 0

func add_score(points):
	score += points * (1 + combo * 0.1)
	combo += 1
	max_combo = max(max_combo, combo)
	
func miss(): 
	combo = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
