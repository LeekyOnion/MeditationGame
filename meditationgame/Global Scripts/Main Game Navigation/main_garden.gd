extends Node
class_name Main_Garden

@export var hud           : CanvasLayer
@export var journal       : Control
@export var inventory_hud : CanvasLayer
@export var rake          : RakeController

@onready var camera = $"Game Camera"
@onready var circle = "res://Objects/Drawing Raycast/RayCastDrawCircle.tscn"

var mode : String = "default"
var is_drawing : bool = false

func _ready() -> void:
	if inventory_hud:
		inventory_hud.close_inventory.connect(_on_inventory_closed)
	if rake:
		rake.rake_active.connect(_on_rake_active)

func _process(delta: float) -> void:
	## While here, position of raycast is constantly updated
	while is_drawing:
		pass
		
## RAYCASTING FUNCTION
func _unhandled_input(event) -> void:
	## This is where the raycast is generated
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		generate_raycast(event)
		
func generate_raycast(event) -> void:
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000.0

	var space_state = get_viewport().get_world_3d().direct_space_state
	
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	
	# Set collide_with_areas to true
	ray_params.collide_with_areas = true
	
	var result = space_state.intersect_ray(ray_params)
	
	if mode == "active":
		## INSTANTIATE CIRCLE AT CREATED AREA
		
		## START DRAW MODE
		
		print("MainGarden: Active Mode Enabled, Now printing!")
			
func _generate_circle() -> void:
	var new_circle_instance = circle.instantiate()
	
func _on_inventory_closed() -> void:
	inventory_hud.visible = false
	hud.visible = true
	
	print("Main_Garden: Inventory closed – HUD & Journal controls visible")

func _on_rake_active() -> void:
	if mode == "default":
		mode = "active"
		print("MainGarden: _on_rake_active() triggered. mode = 'active' ")
		
		if rake and rake.rake_active.is_connected(_on_rake_active):
			rake.rake_active.disconnect(_on_rake_active)
		
	elif mode == "active":
		mode = "default"
		print("MainGarden: Returning to 'default' mode.")
		
	if rake and not rake.rake_active.is_connected(_on_rake_active):
		rake.rake_active.connect(_on_rake_active)
