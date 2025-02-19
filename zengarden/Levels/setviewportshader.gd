extends MeshInstance3D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport := $"../SubViewportContainer/SubViewport" as SubViewport
	print(viewport)
	if viewport:
		print("the viewport is real")
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var material = get_surface_override_material(0)
		if not material:
			print("not a real material")
			material = StandardMaterial3D.new()
			set_surface_override_material(0, material)
		material.albedo_texture = viewport.get_texture()
		#get_surface_override_material(0).albedo_texture = viewport.get_texture() # Replace with function body.
		#pass
	else:
		print("The viewport is not real")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
