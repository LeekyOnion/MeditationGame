extends Control
class_name Journal_Controller

#region SIGNALS
signal close_journal
signal save_journal
#endregion SIGNALS

#region VARIABLES
# EXPORTS
# @export var text_edit     : TextEdit
# @export var background    : ColorRect
# @export var gradient_rect : TextureRect

# SELF
var _num_generator : RandomNumberGenerator = RandomNumberGenerator.new()
var _leaf_counter  : int = 0

# PRELOADS
#var leaf_scene = preload("res://Scenes/Objects/Leaf/Leaf.tscn")
var leaf_scene = preload("res://Scenes/Objects/Leaf/Leaf.tscn")
#endregion VARIABLES

#region COROUTINES
func _ready():
	if leaf_scene:
		print("Journal: Leaf Scene successfully loaded!")
	elif not leaf_scene:
		print("Journal: Leaf Scene Not Loaded!")
	else:
		print("Journal: No Leaf Scene implemented!")
#endregion COROUTINES

#region SELF FUNCTIONS
func _generate_leaf() -> void:	
	## CREATE NEW LEAF INSTANCE
	var new_leaf_instance : Leaf_Object = leaf_scene.instantiate()
	
	## SET LEAF VARIABLES
	## TODO: NAME, SIZE, COLOR, SCALE, ROTATION, SPEED (just to name a few)
	_set_leaf_name(new_leaf_instance)
	_set_leaf_pos(new_leaf_instance)
	
	## ADD LEAD TO SCENE
	add_child(new_leaf_instance)

func _set_leaf_name(leaf_instance : Leaf_Object) -> void:
	_leaf_counter += 1
	
	leaf_instance.name = "Leaf " + str(_leaf_counter)

func _set_leaf_pos(leaf_instance : Leaf_Object) -> void:
	# Get Viewport Information
	# TODO : Have the leaves randomly generate from the top of the viewport
	var viewport_size = get_viewport_rect().size
	var leaf_pos      = Vector2(viewport_size.x - _num_generator.randf_range(0, viewport_size.x), # x
								0)                                                                # y
	
	leaf_instance.global_position = leaf_pos

#func _set_leaf_scale(leaf_instance : Leaf_Object) -> void:
	#leaf_instance.scale = Vector2(leaf_instance.scale_size, leaf_instance.scale_size)
	
func _move_leaves() -> void:
	pass
#endregion SELF FUNCTIONS
	
#region SIGNAL FUNCTIONS
func _on_close_button_pressed() -> void:  # Emits on Close Button pressed
	print("Journal: _on_close_button_pressed(): Exiting. Emitting close_journal")
	close_journal.emit()

func _on_save_button_pressed()  -> void:  # Emits on Save Button pressed
	print("Journal: _on_save_button_pressed(): TODO: Emitting save_journal")
	save_journal.emit()
	
func _on_textbox_caret_changed() -> void: # Emits whenever you type
	var temp_num : int = 0
	temp_num = _num_generator.randi_range(0,9)
	#print("Journal: _on_textbox_carent_changed(): temp_num is: ", temp_num)
	if temp_num > 8:
		#print("Journal: _on_textbox_caret_changed(): RNG Check SUCCESS")
		_generate_leaf()
	else:
		#print("Journal: _on_textbox_carent_changed(): RNG Check FAIL")
		pass
	pass
#endregion SIGNAL FUNCTIONS
