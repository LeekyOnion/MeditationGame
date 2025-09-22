extends MeshInstance3D
class_name RakeController

signal rake_active

func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	pass

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Rake has been clicked on by LMB")
		rake_active.emit()
