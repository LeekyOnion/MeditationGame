extends CanvasLayer
class_name InventoryManager

signal close_inventory;
signal placed_object;

var is_controlling_object : bool = false;
var held_object : Node3D = null;
var target_position : Vector3 = Vector3.ZERO;

@export var item_scenes : Dictionary[int, PackedScene] = {}

func _on_close_button_pressed() -> void:
	close_inventory.emit();

func _on_item_selected(index: int) -> void:
	match index:
		0:
			## Pampas Grass
			_get_held_object(0);
		1:
			## Short Rock
			_get_held_object(1);
		2:
			## Rock Cluster
			_get_held_object(2);
		3:
			## Tall Rock
			_get_held_object(3);
			
	%Inventory.deselect_all();
	%Inventory.set_visible(false);
	
func _process(delta: float) -> void:
	if held_object and is_controlling_object:
		
		var smoothing_speed = 10.0
		
		held_object.global_position = held_object.global_position.lerp(target_position, smoothing_speed * delta)
		
func _unhandled_input(event: InputEvent) -> void:
	if is_controlling_object:
		if event is InputEventMouseMotion:
			_update_drawing_position();
		
		if event.is_action_pressed("place_object"):
			_place_held_object();
		
		if event.is_action_pressed("cancel_action"):
			_remove_held_object();
			
func _get_held_object(index: int) -> void:
	var temporary_object = item_scenes[index];
	var new_instance = temporary_object.instantiate() as Node3D;
	
	%PlacedObjects.add_child(new_instance);
	
	held_object = new_instance;

	target_position = held_object.global_position;
	
	is_controlling_object = true;
	
	%Inventory.set_visible(false);
	
func _place_held_object() -> void:
	held_object.global_position = target_position;
	held_object = null;
	
	is_controlling_object = false;
	
	%Inventory.set_visible(true);

func _remove_held_object() -> void:
	held_object.queue_free();
	held_object = null;
	
	is_controlling_object = false;
	
	%Inventory.set_visible(true);
	
func _update_drawing_position() -> void:
	var mouse_position = get_viewport().get_mouse_position();
	_generate_raycast(mouse_position);

func _generate_raycast(screen_position: Vector2) -> bool:
	var from = %GameCamera.project_ray_origin(screen_position);
	var to = from + %GameCamera.project_ray_normal(screen_position) * 100.0;
	
	var space_state = get_viewport().get_world_3d().direct_space_state;
	
	var ray_parameters : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	ray_parameters.from = from;
	ray_parameters.to = to;
	## collision masks are binary. Instead of using hex codes, just use shifts. 
	## 1 << 0 = layer 1 ... 1 << 31 = layer 32
	ray_parameters.collision_mask = 1 << 3;

	if held_object:
		ray_parameters.exclude = [held_object.get_rid()];
		
	var result : Dictionary = space_state.intersect_ray(ray_parameters);
	
	if result.has("position"):
		var intersection_point = result.position;
		
		target_position = intersection_point;
			
		return true;
		
	return false;
	
