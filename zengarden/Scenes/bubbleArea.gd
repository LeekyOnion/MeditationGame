extends Area2D

var speed = 200.0
var target_position: Vector2
var life_time = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_position = get_viewport().get_visible_rect().size / 2
	$Timer.wait_time = life_time
	$Timer.start()
	
func _physics_process(delta: float) -> void:
	var direction = (target_position - position).normalized()
	position += direction * speed * delta

func _on_timer_timeout():
	queue_free()
	
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var time_diff = abs($Timer.time_left - 0.5)
		var score = clamp(100 - (time_diff * 200),0,100)
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("target"):
		GameManager.miss()
		queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		audio_player.stream = audio_stream
		audio_player.play()
		GameManager.reset()

func _process(delta: float) -> void:
	pass
