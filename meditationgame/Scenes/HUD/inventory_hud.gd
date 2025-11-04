extends CanvasLayer
class_name InventoryHUD

# ---------------------------
# Signals
# ---------------------------
signal item_selected(item_texture: Texture2D)
signal close_inventory  # emitted when Close button is pressed

# ---------------------------
# Exports
# ---------------------------
@export var billboard_sprite_scene: PackedScene
@export var item_textures: Array[Texture2D] = []
@export var button_scene: PackedScene

# ---------------------------
# Nodes
# ---------------------------
@onready var panel: GridContainer = $GridContainer
@onready var close_button: Button = $CloseButton

# ---------------------------
# Dragging state
# ---------------------------
var dragging_item: Sprite3D = null
var dragging_texture: Texture2D = null

# ---------------------------
# Initialization
# ---------------------------
func _ready() -> void:
	print("InventoryHUD: Ready. Generating item buttons...")
	_generate_item_buttons()

	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	else:
		push_warning("InventoryHUD: CloseButton node not found!")

	set_process(false)  # only process when dragging

# ---------------------------
# Generate inventory buttons
# ---------------------------
func _generate_item_buttons() -> void:
	print("InventoryHUD: Generating buttons for", item_textures.size(), "textures...")

	# Clear any existing children
	for child in panel.get_children():
		child.queue_free()

	# Create new buttons for each texture
	for i in range(item_textures.size()):
		var texture = item_textures[i]
		if texture == null:
			push_warning("InventoryHUD: Texture at index %d is null!" % i)
			continue

		var button = button_scene.instantiate() as TextureButton
		var texture_rect = button.get_node("TextureRect") as TextureRect
		texture_rect.texture = texture

		# Store texture reference for later use
		button.set_meta("item_texture", texture)
		button.pressed.connect(_on_item_button_pressed.bind(button))

		panel.add_child(button)
		print(" - Added button for:", texture.resource_path)

# ---------------------------
# Called when a button is clicked
# ---------------------------
func _on_item_button_pressed(button: TextureButton) -> void:
	dragging_texture = button.get_meta("item_texture") as Texture2D

	if dragging_texture == null:
		push_error("InventoryHUD: Button missing item_texture metadata!")
		return

	print("\n[DEBUG] Item button clicked!")
	print(" - Dragging texture path:", dragging_texture.resource_path)

	if billboard_sprite_scene == null:
		push_error("InventoryHUD: billboard_sprite_scene not assigned!")
		return

	dragging_item = billboard_sprite_scene.instantiate() as Sprite3D
	if dragging_item == null:
		push_error("InventoryHUD: Could not instantiate billboard_sprite_scene")
		return

	# Apply the clicked texture recursively to the spawned 3D object
	_apply_texture_to_sprite(dragging_item, dragging_texture)
	print(" - Applied texture to new 3D instance:", dragging_item.name)

	set_process(true)
	print(" - Dragging enabled\n")

# ---------------------------
# Apply texture recursively to Sprite3D
# ---------------------------
func _apply_texture_to_sprite(inst: Sprite3D, texture: Texture2D) -> void:
	
	inst.set_texture(texture)
	inst.pixel_size = 0.0001 # adjust size


	#for child in inst.get_children():
		#_apply_texture_to_sprite(child, texture)

# ---------------------------
# Update dragging position each frame
# ---------------------------
func _process(delta: float) -> void:
	if dragging_item != null:
		var viewport = get_viewport()
		var camera = viewport.get_camera_3d()
		if camera:
			var mouse_pos = viewport.get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

			var space_state = camera.get_world_3d().direct_space_state
			var ray_params = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(ray_params)

			if result:
				dragging_item.global_position = result.position
			else:
				dragging_item.global_position = from + camera.project_ray_normal(mouse_pos) * 5.0

# ---------------------------
# Place item on mouse release
# ---------------------------
func _unhandled_input(event: InputEvent) -> void:
	if dragging_item != null and event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("[DEBUG] Mouse released — placing item and emitting signal.")

			get_tree().get_current_scene().add_child(dragging_item)
			emit_signal("item_selected", dragging_texture)

			print(" - Emitted 'item_selected' signal for:", dragging_texture.resource_path)

			# Clear dragging state
			dragging_item = null
			dragging_texture = null
			set_process(false)

# ---------------------------
# Close inventory button
# ---------------------------
func _on_close_pressed() -> void:
	print("InventoryHUD: Close pressed — emitting 'close_inventory' signal.")
	emit_signal("close_inventory")
