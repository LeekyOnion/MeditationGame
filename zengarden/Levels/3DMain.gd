extends Node3D

var draw_image: Image
var draw_texture: ImageTexture

var is_drawing := false
var last_uv := Vector2()

func _input(event):
	if event.is_action_pressed("click"):
		is_drawing = true
		last_uv = _get_sand_uv()
		print("clicked")
		
	if event.is_action_released("click"):
		is_drawing = false
		print("released")
		
	if is_drawing and event is InputEventMouseButton:
		var new_uv = _get_sand_uv()
		if new_uv != Vector2(-1,-1):
			_paint_between(last_uv, new_uv)
			last_uv = new_uv
			
		print("hello")

func _paint_between(from_uv: Vector2, to_uv: Vector2):
	var img_size = draw_image.get_size()
	var from_pixel = Vector2(from_uv.x * img_size.x, from_uv.y * img_size.y)
	var to_pixel = Vector2(to_uv.x * img_size.x, to_uv.y * img_size.y)
	
	draw_image.lock()
	draw_image.draw_line(from_pixel, to_pixel, Color(1,1,1),5)
	
	draw_image.unlock()
	
	draw_texture.set_data(draw_image)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw_image = Image.new()
	draw_image= Image.create(80, 80, false, Image.FORMAT_RGBA8)
	draw_image.fill(Color(1,1,0,0))
	
	draw_texture = ImageTexture.new()
	draw_texture = ImageTexture.create_from_image(draw_image)
	
	var sand_mesh = get_node("SandMesh")
	if sand_mesh:
		print("sand mesh is real")
		print(sand_mesh)
		var sand_material = sand_mesh.material_override as ShaderMaterial
			
		if sand_material:
			print("sand material is real")
			sand_material.set_shader_parameter("draw_mask", draw_texture)
		else:
			print("Material does not exist")

func _get_sand_uv() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_start = $Camera3D.project_ray_origin(mouse_pos)
	var ray_end = ray_start + $Camera3D.project_ray_normal(mouse_pos) * 1000
	
	$RayCast3D.global_transform.origin = ray_start
	$RayCast3D.target_position = ray_end - ray_start
	$RayCast3D.force_raycast_update()
	
	if $RayCast3D.is_colliding():
		print("Colliding with: ", $RayCast3D.get_collider().name)
		var collider = $RayCast3D.get_collider() as StaticBody3D
		var mesh_inst = collider.get_parent() as MeshInstance3D
		
		if collider == $SandMesh/StaticBody3D:
			return Vector2(mesh_inst.mesh.ARRAY_TEX_UV, mesh_inst.mesh.ARRAY_TEX_UV2)
	
	return Vector2(-1,-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
