extends Node
class_name Main_Garden

@export var hud           : CanvasLayer
@export var journal       : Control
@export var inventory_hud : CanvasLayer
#@export var tile          : GridMap

func _ready() -> void:
	pass

@onready var camera = $"Game Camera"
@onready var openJournal = $MainGarden/SM_SingingBowl_Place_Holder
@onready var breathing_scene = preload("res://BreathingOverlay.tscn")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000.0

		var space_state = get_viewport().get_world_3d().direct_space_state
		var ray_params = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(ray_params)

		if result:
			print("Hit object: ", result.collider.name)
			if result.collider.is_in_group("journal_object"):
				print("Clicked a clickable object, showing journal")
				journal.show_journal()
				
			elif result.collider.is_in_group("breathing_object"):
					print("starting breathing scene")
					var breathing_instance = breathing_scene.instantiate()
					get_tree().root.add_child(breathing_instance)
					self.visible = false
			
			else:
				print("Clicked something but it's not journal")
		else:
			print("No object hit")
			
