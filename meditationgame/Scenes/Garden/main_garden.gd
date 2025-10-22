extends Node
class_name Main_Garden

@export var hud           : CanvasLayer
@export var journal       : Control
@export var inventory_hud : CanvasLayer
@export var rake          : RakeController

@onready var camera = $"Game Camera"

var mode : String = "default"
var is_drawing : bool = false

var current_rake : Node3D = null
var circle_scene = preload("res://Objects/Rake/ShaderRake.tscn")

var previous_position : Vector3 = Vector3.ZERO

func _ready() -> void:
	if inventory_hud:
		inventory_hud.close_inventory.connect(_on_inventory_closed)
	if rake:
		rake.rake_active.connect(_on_rake_active)

func _process(delta: float) -> void:
	## While is_drawing is true, constantly update the position of the single circle
	if is_drawing and current_rake:
		update_drawing_position()
		
func _unhandled_input(event) -> void:
	## Raycast Input
	## START DRAG (Left Mouse Button Pressed)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if mode == "active" and not is_drawing:
			## Only start drawing if a raycast hits something (initial check)
			if generate_raycast(event.position):
				is_drawing = true
				previous_position = current_rake.global_position
				
	## STOP DRAG (Left Mouse Button Released)
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_drawing:
			is_drawing = false
			remove_current_rake()
			
func _generate_circle(position_3d: Vector3) -> void:
	## Instantiate the scene
	var new_circle_instance = circle_scene.instantiate() as Node3D
	
	## Assign it to the tracking variable
	current_rake = new_circle_instance
	
	## Add the circle to the scene tree
	add_child(current_rake)
	
	## Set the initial position
	current_rake.global_position = position_3d
	
func generate_raycast(screen_position: Vector2) -> bool:
	"""
	Performs a raycast from the camera through the given screen position.
	Returns true if a hit occurs and sets the initial circle position.
	"""
	## RAYCASTING
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000.0

	var space_state = get_viewport().get_world_3d().direct_space_state
	
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.collide_with_areas = true
	
	var result = space_state.intersect_ray(ray_params)
	
	## Check the result to see if it has obtained a position
	if result.has("position"):
		var intersection_point = result.position
		#print("POSITION: ", intersection_point)
		
		## Instantiate the circle ONLY on the first hit/click
		if not current_rake:
			_generate_circle(intersection_point)
			print("MainGarden: Created Circle for dragging!")
		else:
			## If the circle already exists, just place it at the hit point
			current_rake.global_position = intersection_point
			
		return true
		
	## If Raycast missed, return false
	else:
		print("MainGarden: Raycast missed, no object or workable surface found.")
		return false

func update_drawing_position() -> void:
	"""
	Called every frame while dragging to update the circle's position.
	"""
	## Get the mouse position without an input event
	var mouse_position = get_viewport().get_mouse_position()
	generate_raycast(mouse_position)
	
	## Generate the raycast and get the new position
	var hit = mouse_position
	
	## If a hit occurred and we have a circle, calculate rotation
	if hit and current_rake:
		_rotate_rake_head(current_rake.global_position)
		previous_position = current_rake.global_position
	
func _rotate_rake_head(current_position: Vector3) -> void:
	"""
	Calculates the movement vector and rotates the current_rake (rake head)
	to face the direction of the drag using explicit rotation calculation.
	"""
	var movement_vector = current_position - previous_position
	
	const MINIMUM_MOVEMENT_SQUARED = 0.0001
	const MULTIPLIER = 1.5
	
	if movement_vector.length_squared() > MINIMUM_MOVEMENT_SQUARED * MULTIPLIER:
		
		## Calculate the Y-rotation angle from the X and Z components.
		## Angle is measured counter-clockwise from the +Z axis.
		var angle = atan2(movement_vector.x, movement_vector.z)
		
		## Apply the rotation directly to the rake.
		## This sets the object's rotation around the Y-axis (Vector3.UP).
		current_rake.rotation.y = angle
		
		## Update the previous position AFTER rotation
		previous_position = current_rake.global_position
		
		print("POSITION: ", current_rake.position, " ANGLE: ", rad_to_deg(current_rake.rotation.y))
		
func remove_current_rake() -> void:
	if current_rake:
		current_rake.queue_free()
		current_rake = null
		print("MainGarden: Dragged circle removed.")

func _on_inventory_closed() -> void:
	inventory_hud.visible = false
	hud.visible = true
	
	print("Main_Garden: Inventory closed – HUD & Journal controls visible")

func _on_rake_active() -> void:
	if mode == "default":
		mode = "active"
		print("MainGarden: _on_rake_active() triggered. mode = 'active' ")
		
		if rake and rake.rake_active.is_connected(_on_rake_active):
			rake.rake_active.disconnect(_on_rake_active)
		
	elif mode == "active":
		mode = "default"
		print("MainGarden: Returning to 'default' mode.")
		
	if rake and not rake.rake_active.is_connected(_on_rake_active):
		rake.rake_active.connect(_on_rake_active)
