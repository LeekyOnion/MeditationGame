extends Node
class_name Main_Garden

# ---------------------------
# Exports
# ---------------------------
@export var hud           : CanvasLayer
@export var journal       : Control
@export var inventory_hud : CanvasLayer
@export var rake          : RakeController

@onready var camera = $"Game Camera"

# ---------------------------
# Dragging state for inventory
# ---------------------------
var dragging_item: Sprite3D = null
var dragging_texture: Texture2D = null

# ---------------------------
# Rake state
# ---------------------------
var mode : String = "default"
var is_drawing : bool = false
var current_rake : Node3D = null
var circle_scene = preload("res://Objects/Rake/ShaderRake.tscn")
var previous_position : Vector3 = Vector3.ZERO

# ---------------------------
# Ready
# ---------------------------
func _ready() -> void:
	if inventory_hud:
		inventory_hud.close_inventory.connect(Callable(self, "_on_inventory_closed"))
		inventory_hud.connect("item_selected", Callable(self, "_on_inventory_item_selected"))

	if rake:
		rake.rake_active.connect(Callable(self, "_on_rake_active"))

# ---------------------------
# Handle input for both inventory dragging and rake drawing
# ---------------------------
func _unhandled_input(event) -> void:
	# -------- Inventory placement --------
	if dragging_item != null and event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if camera == null:
				push_error("Main_Garden: No camera found for raycast!")
				return

			var mouse_pos = event.position
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

			# intersect with XZ plane (y = 0)
			if abs(to.y - from.y) < 0.0001:
				push_warning("Main_Garden: Ray parallel to XZ plane, cannot place item.")
				return

			var t = -from.y / (to.y - from.y)
			var hit_pos = from + (to - from) * t
			hit_pos.y += 0.05  # lift slightly above plane

			# Remove from temporary parent first
			if dragging_item.get_parent():
				dragging_item.get_parent().remove_child(dragging_item)

			# Add item to scene root and set position
			get_tree().get_current_scene().add_child(dragging_item)
			dragging_item.global_position = hit_pos

			print("[DEBUG] Placed item at:", hit_pos)

			# Clear dragging state
			dragging_item = null
			dragging_texture = null

	# -------- Rake drawing --------
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if mode == "active" and not is_drawing:
				if generate_raycast(event.position):
					is_drawing = true
					previous_position = current_rake.global_position
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_drawing:
				is_drawing = false
				remove_current_rake()

# ---------------------------
# Start dragging a new item from inventory
# ---------------------------
func start_dragging_item(item_scene: PackedScene, texture: Texture2D) -> void:
	if item_scene == null or texture == null:
		push_error("Main_Garden: Cannot start dragging, missing scene or texture.")
		return

	# Clean up any existing dragging item
	if dragging_item != null:
		if dragging_item.get_parent():
			dragging_item.get_parent().remove_child(dragging_item)
		dragging_item.queue_free()
		dragging_item = null

	# Create new dragging item
	var new_item = item_scene.instantiate()
	dragging_texture = texture
	
	# Check if it's a Sprite3D or if we need to find the Sprite3D child
	if new_item is Sprite3D:
		dragging_item = new_item as Sprite3D
		dragging_item.texture = dragging_texture
		dragging_item.pixel_size = 0.2
		dragging_item.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		print("[DEBUG] Started dragging (Sprite3D):", dragging_texture.resource_path)
	else:
		# If the root is not Sprite3D, try to find it as a child
		var sprite_child = new_item.find_child("Sprite3D", true, false)
		if sprite_child and sprite_child is Sprite3D:
			dragging_item = sprite_child as Sprite3D
			dragging_item.texture = dragging_texture
			dragging_item.pixel_size = 0.2
			dragging_item.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			print("[DEBUG] Started dragging (child Sprite3D):", dragging_texture.resource_path)
		else:
			push_error("Main_Garden: Could not find Sprite3D in scene!")
			new_item.queue_free()
			return

func _on_inventory_item_selected(texture: Texture2D) -> void:
	print("[DEBUG] Main_Garden received item selection signal")
	if inventory_hud is InventoryHUD:
		var hud_ref = inventory_hud as InventoryHUD
		if hud_ref.billboard_sprite != null:
			print("[DEBUG] Billboard sprite found, starting drag")
			start_dragging_item(hud_ref.billboard_sprite, texture)
		else:
			push_error("Main_Garden: billboard_sprite is null in InventoryHUD")

# ---------------------------
# Process - Update dragging item position
# ---------------------------
func _process(_delta: float) -> void:
	# Update dragging item position to follow mouse
	if dragging_item != null and camera != null:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
		
		# intersect with XZ plane (y = 0)
		if abs(to.y - from.y) > 0.0001:
			var t = -from.y / (to.y - from.y)
			var hit_pos = from + (to - from) * t
			hit_pos.y += 0.05
			
			# Add to scene if not already added
			if not dragging_item.is_inside_tree():
				add_child(dragging_item)
			
			dragging_item.global_position = hit_pos
	
	# Update rake drawing
	if is_drawing and mode == "active":
		update_drawing_position()

# ---------------------------
# Rake helper functions
# ---------------------------
func _generate_circle(position_3d: Vector3) -> void:
	var new_circle_instance = circle_scene.instantiate() as Node3D
	current_rake = new_circle_instance
	add_child(current_rake)
	current_rake.global_position = position_3d

func generate_raycast(screen_position: Vector2) -> bool:
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000.0
	var space_state = get_viewport().get_world_3d().direct_space_state

	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.collide_with_areas = true

	var result = space_state.intersect_ray(ray_params)
	if result.has("position"):
		var intersection_point = result.position
		if not current_rake:
			_generate_circle(intersection_point)
			print("MainGarden: Created Circle for dragging!")
		else:
			current_rake.global_position = intersection_point
		return true
	return false

func update_drawing_position() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	if generate_raycast(mouse_position) and current_rake:
		_rotate_rake_head(current_rake.global_position)
		previous_position = current_rake.global_position

func _rotate_rake_head(current_position: Vector3) -> void:
	var movement_vector = current_position - previous_position
	const MINIMUM_MOVEMENT_SQUARED = 0.0001
	const MULTIPLIER = 1.5
	if movement_vector.length_squared() > MINIMUM_MOVEMENT_SQUARED * MULTIPLIER:
		var angle = atan2(movement_vector.x, movement_vector.z)
		current_rake.rotation.y = angle
		previous_position = current_rake.global_position
		print("POSITION: ", current_rake.position, " ANGLE: ", rad_to_deg(current_rake.rotation.y))

func remove_current_rake() -> void:
	if current_rake:
		current_rake.queue_free()
		current_rake = null
		print("MainGarden: Dragged circle removed.")

# ---------------------------
# Inventory close
# ---------------------------
func _on_inventory_closed() -> void:
	# Clean up any dragging item when inventory closes
	if dragging_item != null:
		if dragging_item.get_parent():
			dragging_item.get_parent().remove_child(dragging_item)
		dragging_item.queue_free()
		dragging_item = null
	
	inventory_hud.visible = false
	hud.visible = true
	print("Main_Garden: Inventory closed – HUD & Journal controls visible")

# ---------------------------
# Rake active toggle
# ---------------------------
func _on_rake_active() -> void:
	if mode == "default":
		mode = "active"
		print("MainGarden: _on_rake_active() triggered. mode = 'active'")
		if rake and rake.rake_active.is_connected(Callable(self, "_on_rake_active")):
			rake.rake_active.disconnect(Callable(self, "_on_rake_active"))
	elif mode == "active":
		mode = "default"
		print("MainGarden: Returning to 'default' mode.")
	if rake and not rake.rake_active.is_connected(Callable(self, "_on_rake_active")):
		rake.rake_active.connect(Callable(self, "_on_rake_active"))
