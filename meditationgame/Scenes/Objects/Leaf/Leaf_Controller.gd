extends RigidBody2D
class_name Leaf_Object

#region VARIABLES
# Export
@export var Leaf         : Leaf_Model
@export var delete_timer : Timer

# Self Variables
#endregion VARIABLES

#region COROUTINES
func _ready() -> void:
	if is_instance_valid(delete_timer):
		delete_timer.timeout.connect(_on_delete_timer_timeout)
		delete_timer.start()
	else:
		printerr("Leaf_Object: 'delete_timer' is not assigned or not a valid Timer node.")

func _process(_delta: float) -> void:
	pass
#endregion COROUTINES

#region SIGNALS
func _on_delete_timer_timeout() -> void:
	queue_free()
#endregion SIGNALS
