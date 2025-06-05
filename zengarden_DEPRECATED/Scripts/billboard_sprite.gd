#Manages the functionality for each billboard sprite spawned in as a decoration
#from the MainGarden inventory HUD.
#Raycast code from here and AustinDraw can probably be made into its own class,
#as it is the same code between the two.
extends Node3D
class_name BillboardSprite

@onready var sprite : Sprite3D = $Sprite3D

@export var _texture : Texture2D
@export var grid_map : GridMap

var selected = false
var mouse_offset = Vector3(0, 0, 0)
var tile_size = Vector3(0, 0, 0)
var input_event : InputEventMouseButton

const RAY_LENGTH := 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _texture != null and grid_map != null:
		sprite.texture = _texture
		tile_size = grid_map.cell_size
	scale = Vector3(8, 8, 8) #Change when needed, just thought it was a fine size for now

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Similar code to the raking. When holding right click on the billboard sprite,
	#it will follow the mouse's position, snapping to the closest point on the MainGarden grid map.
	if input_event != null and Input.is_action_just_released("right_click"):
		selected = false
		input_event = null
	if selected:
		followMouse()

#collision_mask is the default bitmask in Godot to detect 3D collisions between a raycast and object
func _do_raycast_on_mouse_position(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	# Raycast related code to detect any objects in the path of a raycast from the camera to the current mouse position.
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_ray(query) # raycast result
	return result

# Gets ray-cast hit position from camera to world.
# @return Vector3 or null
#collision_mask is the default bitmask in Godot to detect 3D collisions between a raycast and object
func get_mouse_world_position(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	var raycast_result = _do_raycast_on_mouse_position(collision_mask)
	if raycast_result:
		return raycast_result.position
	return null

# Gets ray-cast hit object from camera to world. Not currently used, but here if needed in future.
# @return Object or null
#collision_mask is the default bitmask in Godot to detect 3D collisions between a raycast and object
func get_raycast_hit_object(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	var raycast_result = _do_raycast_on_mouse_position(collision_mask)
	if raycast_result:
		return raycast_result.collider
	return null

func followMouse():
	if get_mouse_world_position() != null:
		var pos = get_mouse_world_position()
		position = pos.snapped(Vector3(tile_size.x, 0, tile_size.z))
		position.y = 4

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		input_event = event
		if event.pressed:
			selected = true
