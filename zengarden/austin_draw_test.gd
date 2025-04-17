extends Node3D

const RAY_LENGTH := 1000
@export var mesh : MeshInstance3D

@onready var viewport := $SubViewportContainer/SubViewport as SubViewport
@onready var sprite := $SubViewportContainer/SubViewport/Sprite2D as Sprite2D
@onready var sand_tex = load("uid://dpni7xv27k32k") as Texture2D
@onready var black_tex = load("uid://jx07kg3xq5gb") as Texture2D
@onready var mask_img : Image
@onready var sand_img : Image
@onready var black_img : Image

var mouse_pos
var prev_mouse_pos = Vector3(0, 0, 0)
var sand_material : StandardMaterial3D
var blend_material : StandardMaterial3D
var shader : ShaderMaterial
var past_changes : Array[Texture]

func _ready() -> void:
	'''if viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var draw_material = mesh.get_surface_override_material(0)
		if not draw_material:
			draw_material = StandardMaterial3D.new()
			mesh.set_surface_override_material(0, draw_material)
		draw_material.albedo_texture = viewport.get_texture()'''
	shader = mesh.mesh.surface_get_material(0)
	
	if mesh != null and sand_tex != null and viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		sand_material = StandardMaterial3D.new()
		sand_material.albedo_texture = sand_tex
		'''sand_material.detail_enabled = true
		sand_material.albedo_texture = sand_tex
		sand_material.detail_albedo = viewport.get_texture()
		sand_material.detail_mask = viewport.get_texture()'''
		#mesh.set_surface_override_material(0, sand_material)
		mesh.mesh.surface_set_material(0, sand_material)
		
		blend_material = StandardMaterial3D.new()
		blend_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		blend_material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
		blend_material.detail_enabled = true
		blend_material.detail_albedo = black_tex
		#blend_material.detail_mask = viewport.get_texture()
		blend_material.albedo_texture = viewport.get_texture()
		mesh.material_overlay = blend_material

func _process(delta: float) -> void:
	if get_mouse_world_position() != null:
		mouse_pos = get_mouse_world_position()
		sprite.global_position = Vector2(mouse_pos.x * 8, mouse_pos.z * 8)
		sprite.look_at(Vector2(prev_mouse_pos.x * 8, prev_mouse_pos.z * 8))
		prev_mouse_pos = mouse_pos

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
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			mask_img = viewport.get_texture().get_image()
			'''sand_img = sand_tex.get_image()
			black_img = black_tex.get_image()
			
			mask_img.convert(Image.FORMAT_RGBA8)
			sand_img.convert(Image.FORMAT_RGBA8)
			black_img.convert(Image.FORMAT_RGBA8)
			
			var size : Vector2 = Vector2(viewport.get_texture().get_width(), viewport.get_texture().get_height())
			var rect : Rect2 = Rect2(Vector2.ZERO, size)
			
			#mask_img.lock()
			for x in range(size.x):
				for y in range(size.y):
					var color : Color = mask_img.get_pixel(x, y)
					color.a = 0.5
					mask_img.set_pixel(x, y, color)
			#mask_img.unlock()
			sand_img.blend_rect(mask_img, rect, Vector2.ZERO)
			
			sand_img.resize(mask_img.get_width(), mask_img.get_height())
			var blend_img : Image = sand_img.duplicate()
			
			blend_img.blend_rect_mask(black_img, mask_img, rect, viewport.get_mouse_position())
			sand_img.save_png("res://ArtAssets/Textures/Blend.png")'''

			#if the image is compressed, decompress it
			'''if mask_img.is_compressed():mask_img.decompress()
			if sand_img.is_compressed():sand_img.decompress()
			
			mask_img.convert(Image.FORMAT_RGBA8)
			sand_img.convert(Image.FORMAT_RGBA8)
			#resize the image to match the mask size
			if sand_img.get_size() != mask_img.get_size():
				sand_img.resize(mask_img.get_width(), mask_img.get_height())
			
			var temp_img = sand_img.duplicate()
			for y in temp_img.get_height():
				for x in temp_img.get_width():
					temp_img.set_pixel(x,y,Color.BLACK)
			
			var rect = Rect2i(Vector2i.ZERO, mask_img.get_size())
			sand_img.blend_rect_mask(temp_img, mask_img, rect, Vector2i.ZERO)
			var blend_tex = ImageTexture.create_from_image(sand_img)'''
			var mask_tex = ImageTexture.create_from_image(mask_img)
			if past_changes.size() >= 3:
				past_changes.pop_front()
			past_changes.push_back(mask_tex)

			#var blend_material = StandardMaterial3D.new()
			#blend_material.detail_enabled = true
			#blend_material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			#blend_material.albedo_texture = mask_tex
			#blend_material.detail_albedo = mask_tex
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
			
			mesh.mesh.surface_set_material(0, shader)
			
			#blend_material.albedo_texture = mask_tex
			'''sand_material.detail_enabled = true
			sand_material.detail_albedo = mask_tex
			sand_material.detail_mask = black_tex'''
			#sand_material.albedo_texture = mask_tex
			#mesh.set_surface_override_material(0, blend_material)
			
			# When you need to clear once:
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			await get_tree().process_frame
			#viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
