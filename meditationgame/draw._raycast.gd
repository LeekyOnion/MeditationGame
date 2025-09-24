extends RayCast3D
class_name Draw_Raycast_3D

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	# Check if Raycast has collided with object
	if is_colliding():
		var collision_point = get_collision_point()
		
		print("Draw Raycast: Collided with object at: ", collision_point)
