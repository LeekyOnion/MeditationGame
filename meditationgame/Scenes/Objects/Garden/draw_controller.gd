extends Node3D
class_name DrawController

@export var RakeObject: RakeController
@export var Draw_Raycast : Draw_Raycast_3D

var draw_enabled : bool = false

func _ready() -> void:
	RakeObject.rake_active.connect(_enable_draw_mode)
	#Draw_Raycast.target_position = Vector3(0, 0, -1)
	#Draw_Raycast.enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if draw_enabled:
		if Input.is_action_just_pressed("left_click"):
			# Get the 3D position where the raycast should end
			var mouse_pos_3d = get_mouse_collision_point()
			
			if mouse_pos_3d != null:
				# Convert the world position to the RayCast3D's local space
				var local_target_position = Draw_Raycast.to_local(mouse_pos_3d)
				
				# Set the raycast's target position
				Draw_Raycast.target_position = local_target_position
				
				# Force an update to see the collision immediately
				Draw_Raycast.force_raycast_update()
				
				# Check for a collision and print the result
				if Draw_Raycast.is_colliding():
					print("Raycast hit object at ", Draw_Raycast.get_collision_point())

func _enable_draw_mode() -> void:
	if not draw_enabled:
		print("DrawController: Draw Mode Enabled!")
		draw_enabled = true
	else:
		print("DrawController: Draw Mode Disabled!")
		draw_enabled = false

func get_mouse_collision_point() -> Variant:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return null
	
	# Cast a ray from the camera through the mouse position.
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	
	# Create a physics query to find the collision point.
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result.has("position"):
		return result.position
	
	return null
