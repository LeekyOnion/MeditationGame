extends Wind_Component
class_name Wind_Journal

"""
This is currently hard-coded to test for rect shape only. 
Shape is not modular at the moment.
"""
#region VARIABLES
# EXPORT
@export var windbox_size_x : float
@export var windbox_size_y : float
@export var windbox_range_lift_max : float # NEGATIVE pushes Object UP
@export var windbox_range_lift_min : float # POSITIVE pushes Object DOWN
@export var windbox_range_lr_max   : float # NEGATIVE pushes Object LEFT
@export var windbox_range_lr_min   : float # POSITIVE pushes Object RIGHT


@export var detection_area : CollisionShape2D

# SELF
var _num_generator : RandomNumberGenerator = RandomNumberGenerator.new()
#endregion VARIABLES

func _ready() -> void:
	if is_instance_valid(detection_area) and detection_area.shape is RectangleShape2D:
		detection_area.shape.get_rect().size.x
		var detection_shape = detection_area.shape as RectangleShape2D
		detection_shape.size.x = windbox_size_x
		detection_shape.size.y = windbox_size_y
		
		print("windbox x: ",  detection_shape.size.x)
		print("windbox y: ",  detection_shape.size.y)
	
func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

#region SIGNALS
func _on_body_entered(body: Node2D) -> void:
	print("Wind Area: ", body, " has entered!")
	var temp_x : float
	var temp_y : float
	
	temp_x = _num_generator.randf_range(windbox_range_lr_max, 
										windbox_range_lr_min)
	temp_y = _num_generator.randf_range(windbox_range_lift_max, 
										windbox_range_lift_min)

	print("temp x: ", temp_x)
	print("temp y: ", temp_y)
	
	if body is RigidBody2D:
		body as RigidBody2D
		body.apply_impulse(Vector2(temp_x, temp_y))
		#body.apply_torque(1.0)
#endregion SIGNALS
