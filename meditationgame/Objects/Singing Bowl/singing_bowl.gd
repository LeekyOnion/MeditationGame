extends Node3D
class_name SingingBowlController

@onready var breathing_scene = preload("res://Scenes/Breathing/BreathingOverlay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("SingingBowlController: SingingBowl has been clicked on by the LMB")
		
		var breathing_instance = breathing_scene.instantiate()
		get_tree().root.add_child(breathing_instance)
