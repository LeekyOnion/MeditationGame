#Script to handle the raking interaction with the garden that lives in the MainGarden scene.
#Raycast code from here and BillboardSprite can probably be made into its own class,
#as it is the same code between the two.
extends Node3D
class_name AustinDraw

const RAY_LENGTH := 1000 #How far the raycast is shot out from the camera
@export var mesh : MeshInstance3D

#References to the textures and nodes required to make the raking functional.
@onready var viewport := $SubViewportContainer/SubViewport as SubViewport
@onready var sprite := $SubViewportContainer/SubViewport/Sprite2D as Sprite2D
@onready var sand_tex = load("uid://dpni7xv27k32k") as Texture2D
@onready var black_tex = load("uid://jx07kg3xq5gb") as Texture2D

var mask_img : Image
var sand_img : Image
var black_img : Image
var mouse_pos
var prev_mouse_pos = Vector3(0, 0, 0)
var sand_material : StandardMaterial3D
var blend_material : StandardMaterial3D
var shader : ShaderMaterial
var past_changes : Array[Texture] #Array of data involving the past few rakes that will blend together in GroundDraw.gsdhader

func _ready() -> void:
	shader = mesh.mesh.surface_get_material(0) #Reference to GroundDraw.gdshader on the ground mesh
	
	#Setting up base visual for garden ground
	if mesh != null and sand_tex != null and viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		sand_material = StandardMaterial3D.new()
		sand_material.albedo_texture = sand_tex
		mesh.mesh.surface_set_material(0, sand_material)
		
		blend_material = StandardMaterial3D.new()
		blend_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		blend_material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
		blend_material.detail_enabled = true
		blend_material.detail_albedo = black_tex
		blend_material.albedo_texture = viewport.get_texture()
		mesh.material_overlay = blend_material

func _process(delta: float) -> void:
	#Viewport with a Sprite2D is rendered onto the garden ground mesh.
	#The Sprite2D follows the position of your mouse as it's position is raycast from the camera to the 3D world.
	#This gives off a rake cursor effect that can change viewport update and clear modes to create the raked sand effect.
	if get_mouse_world_position() != null:
		mouse_pos = get_mouse_world_position()
		sprite.global_position = Vector2(mouse_pos.x * 8, mouse_pos.z * 8)  #8 is an offset to fill the entire ground mesh space
		sprite.look_at(Vector2(prev_mouse_pos.x * 8, prev_mouse_pos.z * 8)) #Cursor rotation effect
		prev_mouse_pos = mouse_pos

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

func _on_mouse_clicked(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: #Detecting left mouse click
		if event.pressed:
			#Changing viewport update and clear modes when holding left click to make the Sprite2D cursor smear, creating the raked sand effect
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			#Snap an image of the current state of the viewport and convert it to a texture
			mask_img = viewport.get_texture().get_image()
			var mask_tex = ImageTexture.create_from_image(mask_img)
			
			#Add new viewport texture into an array to store the last few rakes.
			#Feel free to increase how many changes are allowed before wiping the oldest,
			#you'll just need to add some new mix functions to the GroundDraw.gdshader to mix every texture properly.
			if past_changes.size() >= 3:
				past_changes.pop_front()
			past_changes.push_back(mask_tex)
			
			#Setting all the GroundDraw.gdshader parameters
			shader.set_shader_parameter("base_tex", sand_tex)
			shader.set_shader_parameter("amount_changes", past_changes.size())
			
			match past_changes.size():
				1:
					shader.set_shader_parameter("blend_tex_1", past_changes[0])
				2:
					shader.set_shader_parameter("blend_tex_1", past_changes[0])
					shader.set_shader_parameter("blend_tex_2", past_changes[1])
				3:
					shader.set_shader_parameter("blend_tex_1", past_changes[0])
					shader.set_shader_parameter("blend_tex_2", past_changes[1])
					shader.set_shader_parameter("blend_tex_3", past_changes[2])
			
			#Updating material of garden ground to include the mix of raked lines
			mesh.mesh.surface_set_material(0, shader)
			
			#Switch back update and clear modes to reset the process
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			await get_tree().process_frame
