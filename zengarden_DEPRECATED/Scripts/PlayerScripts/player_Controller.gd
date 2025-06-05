extends CharacterBody2D

# Player movement variables
@export var speed: float = 200.0  # Speed of the player
@export var inv : Inv

func _physics_process(delta: float) -> void:
	# Get input for movement
	var direction: Vector2 = Vector2.ZERO

#redundant 2d controls
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	# Normalize the direction vector to prevent faster diagonal movement
	if direction.length() > 0:
		direction = direction.normalized()

	# Apply movement
	velocity = direction * speed
	move_and_slide()
