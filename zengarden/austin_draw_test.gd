extends Node3D

const RAY_LENGTH := 1000
@onready var shader = load("res://ArtAssets/Shaders/Sand.gdshader") as Shader
@onready var viewport := $SubViewportContainer/SubViewport as SubViewport
@onready var sprite := $SubViewportContainer/SubViewport/Sprite2D as Sprite2D
@onready var mesh := $MeshInstance3D as MeshInstance3D

var material : StandardMaterial3D

func _ready() -> void:
	if shader != null and viewport != null:
		#shader.set_shader_parameter("draw_mask", viewport.get_texture())
		print(shader.get_shader_uniform_list())
	
	if viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		material = mesh.get_surface_override_material(0)
		if not material:
			material = StandardMaterial3D.new()
			mesh.set_surface_override_material(0, material)
		material.albedo_texture = viewport.get_texture()

func _process(delta: float) -> void:
	if get_mouse_world_position() != null:
		var mouse_pos = get_mouse_world_position()
		#print(mouse_pos)
		sprite.global_position = Vector2(mouse_pos.x * 8, mouse_pos.z * 8)

func _do_raycast_on_mouse_position(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	# Raycast related code
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
func get_mouse_world_position(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	var raycast_result = _do_raycast_on_mouse_position(collision_mask)
	if raycast_result:
		return raycast_result.position
	return null

# Gets ray-cast hit object from camera to world.
# @return Object or null
func get_raycast_hit_object(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	var raycast_result = _do_raycast_on_mouse_position(collision_mask)
	if raycast_result:
		return raycast_result.collider
	return null

func _on_mouse_clicked(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
		else:
			await RenderingServer.frame_post_draw
			var tex = ImageTexture.create_from_image(viewport.get_texture().get_image()) as ImageTexture
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
