extends Node
class_name RakeGame

signal exit_rake_mode;

var rake_drawing_shape = preload("res://01_Entities/Rake/ShaderRake.tscn");

var is_drawing : bool = false;
var current_rake : Node3D = null;

var previous_position : Vector3 = Vector3.ZERO;
var target_rotation_y : float = 0.0;
var rotation_speed : float = 15.0 ;

func _on_button_pressed() -> void:
	exit_rake_mode.emit();
	_remove_current_rake();
	
func _on_rake_active() -> void:
	current_rake = rake_drawing_shape.instantiate() as Node3D;
	add_child(current_rake);
	
	await get_tree().process_frame;
	
	var center_of_screen : Vector2 = get_viewport().size / 2.0;
	
	if _place_rake_in_air(center_of_screen):
		previous_position = current_rake.global_position;
		#is_active = true;
	else:
		_remove_current_rake();
		printerr("Rake activation failed: Could not find initial position for suspension.");
	
	
func _process(delta: float) -> void:
	if current_rake:
		current_rake.rotation.y = lerp_angle(current_rake.rotation.y, target_rotation_y, rotation_speed * delta)
		_update_drawing_position();
		
func _unhandled_input(event) -> void:
	if event.is_action_pressed("interact"):
		if !is_drawing:
			if _generate_raycast(event.position):
				is_drawing = true;
				previous_position = current_rake.global_position;

	elif event.is_action_released("interact"):
		if is_drawing:
			is_drawing = false;
	
	if current_rake and !is_drawing:
		if event is InputEventMouseMotion:
			_update_drawing_position();

func _generate_raycast(screen_position: Vector2) -> bool:
	var from = %GameCamera.project_ray_origin(screen_position);
	var to = from + %GameCamera.project_ray_normal(screen_position) * 100.0;
	var space_state = get_viewport().get_world_3d().direct_space_state;

	var ray_parameters : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	ray_parameters.from = from;
	ray_parameters.to = to;
	ray_parameters.collision_mask = 1 << 3;

	var result : Dictionary = space_state.intersect_ray(ray_parameters);
	if result.has("position"):
		var intersection_point = result.position;
		current_rake.global_position = intersection_point;
		return true;
		
	return false;
	
func _place_rake_in_air(screen_position: Vector2) -> bool:
	var from = %GameCamera.project_ray_origin(screen_position);
	var to = from + %GameCamera.project_ray_normal(screen_position) * 100.0;
	var space_state = get_viewport().get_world_3d().direct_space_state

	var ray_parameters : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	ray_parameters.collision_mask = 1 << 3; 

	var result : Dictionary = space_state.intersect_ray(ray_parameters);
	
	if result.has("position"):
		var intersection_point = result.position;
		
		current_rake.global_position = intersection_point + Vector3.UP / 12.0;
		return true;
		
	return false;
	
func _update_drawing_position() -> void:
	var mouse_position = get_viewport().get_mouse_position();
	if _generate_raycast(mouse_position) and current_rake:
		if is_drawing:
			_rotate_rake_head(current_rake.global_position);
			previous_position = current_rake.global_position;
		elif !is_drawing:
			current_rake.global_position += Vector3.UP / 12.0;
			_rotate_rake_head(current_rake.global_position);
			previous_position = current_rake.global_position;
		
func _rotate_rake_head(current_position: Vector3) -> void:
	var movement_vector = current_position - previous_position
	var minimum_movement = 0.0001;
	
	if movement_vector.length() > minimum_movement:
		target_rotation_y = atan2(movement_vector.x, movement_vector.z)
		
	previous_position = current_position

func _remove_current_rake() -> void:
	if current_rake:
		current_rake.queue_free();
		current_rake = null;
