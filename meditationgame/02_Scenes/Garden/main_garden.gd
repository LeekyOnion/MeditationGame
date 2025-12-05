extends Node
class_name Main_Garden

## Variables
@export var hud           : CanvasLayer
@export var journal       : Control
@export var inventory_hud : CanvasLayer
@export var rake          : RakeController

@onready var camera = $"Game Camera"

var dragging_item: Sprite3D = null
var dragging_texture: Texture2D = null

var mode : String = "default"
var is_drawing : bool = false
var current_rake : Node3D = null
var circle_scene = preload("res://01_Entities/Rake/ShaderRake.tscn")
var previous_position : Vector3 = Vector3.ZERO

enum string{neutral, journalling, raking, placing} 

func _ready() -> void:
	if inventory_hud:
		inventory_hud.close_inventory.connect(Callable(self, "_on_inventory_closed"))
		inventory_hud.connect("item_selected", Callable(self, "_on_inventory_item_selected"))

	if rake:
		rake.rake_active.connect(Callable(self, "_on_rake_active"))

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

func _unhandled_input(event) -> void:
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
	const MINIMUM_MOVEMENT_SQUARED = 0.01
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

## SIGNAL LIST ##
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

func _on_inventory_item_selected() -> void:
	#print("[DEBUG] Main_Garden received item selection signal")
	#if inventory_hud is InventoryHUD:
		#var hud_ref = inventory_hud as InventoryHUD
		#if hud_ref.billboard_sprite != null:
			#print("[DEBUG] Billboard sprite found, starting drag")
			#start_dragging_item(hud_ref.billboard_sprite)
		#else:
			#push_error("Main_Garden: billboard_sprite is null in InventoryHUD")
	pass

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
