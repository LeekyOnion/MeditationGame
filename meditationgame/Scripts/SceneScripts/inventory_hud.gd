extends CanvasLayer
class_name InventoryHUD

# Signals
signal item_selected(item_texture: Texture2D)
signal close_inventory  # emitted when Close button is pressed

# Exports
@export var billboard_sprite_scene: PackedScene
@export var item_textures: Array[Texture2D] = []
@export var button_scene: PackedScene

# Nodes
@onready var panel: GridContainer = $GridContainer
@onready var close_button: Button = $CloseButton

# Dragging state
var dragging_item: Node3D = null
var dragging_texture: Texture2D = null

func _ready() -> void:
	_generate_item_buttons()
	if close_button != null:
		close_button.pressed.connect(_on_close_pressed)
	else:
		push_warning("CloseButton node not found!")
	set_process(false)  # only process when dragging

# Generate inventory buttons
func _generate_item_buttons() -> void:
	for child in panel.get_children():
		child.queue_free()

	for texture in item_textures:
		var button = button_scene.instantiate() as TextureButton
		var texture_rect = button.get_node("TextureRect") as TextureRect
		texture_rect.texture = texture

		# Store texture for click event
		button.set_meta("item_texture", texture)
		button.pressed.connect(_on_item_button_pressed.bind(button))
		panel.add_child(button)

# Recursively find Sprite3D and assign texture
func _apply_texture_to_sprite(inst: Node, texture: Texture2D) -> void:
	if inst is Sprite3D:
		inst.texture = texture
		inst.scale = Vector3(0.1, 0.1, 0.1)  # adjust size
		return
	for child in inst.get_children():
		_apply_texture_to_sprite(child, texture)

# Called when a button is clicked
func _on_item_button_pressed(button: TextureButton) -> void:
	dragging_texture = button.get_meta("item_texture") as Texture2D
	if billboard_sprite_scene == null:
		push_error("InventoryHUD: billboard_sprite_scene not assigned!")
		return

	dragging_item = billboard_sprite_scene.instantiate() as Node3D
	if dragging_item == null:
		push_error("InventoryHUD: Could not instantiate billboard_sprite_scene")
		return

	# Apply the correct texture recursively
	_apply_texture_to_sprite(dragging_item, dragging_texture)

	set_process(true)  # enable dragging

# Update dragging position each frame
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

# Place item on mouse release
func _unhandled_input(event: InputEvent) -> void:
	if dragging_item != null and event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Add to current scene
			get_tree().get_current_scene().add_child(dragging_item)
			emit_signal("item_selected", dragging_texture)

			# Clear dragging state
			dragging_item = null
			dragging_texture = null
			set_process(false)

# Close inventory button
func _on_close_pressed() -> void:
	print("InventoryHUD: _on_close_pressed() called. Emitting close_inventory signal")
	emit_signal("close_inventory")
