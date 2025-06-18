extends RigidBody2D
class_name Leaf_Object

#region VARIABLES
# Export
@export var leaf_data    : Leaf_Model
@export var delete_timer : Timer
@export_range(0.05, 1.00) var scale_size   : float

# Self Variables
@onready var _sprite  = $Sprite
@onready var _collider = $Collider

var _num_generator : RandomNumberGenerator = RandomNumberGenerator.new()
#endregion VARIABLES

#region COROUTINES
func _ready() -> void:
	if is_instance_valid(delete_timer):
		#apply_scale(Vector2(scale_size, scale_size))
		print("Leaf Scale: ",  scale)
		#delete_timer.start()
	else:
		printerr("Leaf_Object: 'delete_timer' is not assigned or not a valid Timer node.")
	
	if is_instance_valid(_sprite):
		_sprite.scale = Vector2(scale_size, scale_size)
	else:
		printerr("Leaf_Object: '_sprite' is not found.")
	
	if is_instance_valid(_collider):
		_collider.scale = Vector2(scale_size, scale_size)
	else:
		printerr("Leaf_Object: '_collider' is not found.")
	
func _process(_delta: float) -> void:
	pass
#endregion COROUTINES

#region SIGNALS
func _on_delete_timer_timeout() -> void: # Self Delete
	queue_free()

func _on_move_timer_timeout() -> void:   # Determines if it should updraft
	var temp_num : int = 0
	temp_num   = _num_generator.randi_range(0,9)
	var temp_x = _num_generator.randf_range(-0.33, 0)
	var temp_y = _num_generator.randf_range(0, -0.33)
	#print("Journal: _on_textbox_carent_changed(): temp_num is: ", temp_num)
	if temp_num > 6:
		apply_impulse(Vector2(temp_x, temp_y)) # Vector2(x, y)
	else:
		pass
	pass
#endregion SIGNALS
