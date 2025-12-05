extends Control
class_name JournalGame

signal close_journal
signal save_journal

var _num_generator : RandomNumberGenerator = RandomNumberGenerator.new()
var _leaf_counter  : int = 0

var leaf_scene = preload("res://01_Entities/Leaf/Leaf.tscn")

func _ready():
	if leaf_scene:
		print("JournalMenu: Leaf Scene successfully loaded!")
	elif not leaf_scene:
		print("JournalMenu: Leaf Scene Not Loaded!")
	else:
		print("JournalMenu: No Leaf Scene implemented!")

func _generate_leaf() -> void:
	var new_leaf_instance : Leaf_Object = leaf_scene.instantiate()
	
	_set_leaf_name(new_leaf_instance)
	_set_leaf_pos(new_leaf_instance)
	
	add_child(new_leaf_instance)

func _set_leaf_name(leaf_instance : Leaf_Object) -> void:
	_leaf_counter += 1
	leaf_instance.name = "Leaf " + str(_leaf_counter)

func _set_leaf_pos(leaf_instance : Leaf_Object) -> void:
	var viewport_size = get_viewport_rect().size;
	var leaf_pos = Vector2(viewport_size.x - _num_generator.randf_range(0.0, viewport_size.x), 0.0);
	
	leaf_instance.global_position = leaf_pos;
	
func _cleanup_leaves() -> void:
	for child in get_children():
		if child is Leaf_Object:
			child.queue_free()
			
func _on_close_button_pressed() -> void:
	_cleanup_leaves();
	close_journal.emit()

func _on_save_button_pressed()  -> void:
	print("JournalMenu: _on_save_button_pressed(): TODO: Emitting save_journal")
	## TODO: Save the journal entry!
	save_journal.emit()
	
func _on_textbox_caret_changed() -> void:
	var temp_num : int = 0
	temp_num = _num_generator.randi_range(0,9)
	if temp_num > 8:
		_generate_leaf()
	else:
		pass
	pass
