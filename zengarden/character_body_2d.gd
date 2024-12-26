extends CharacterBody2D

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	print(input_vector)
	
	if input_vector:
		velocity = input_vector * 300
	else:
		velocity = input_vector
	move_and_slide()
