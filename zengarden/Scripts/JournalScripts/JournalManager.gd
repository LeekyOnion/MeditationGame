extends Control

@onready var text_edit = $TextEdit
@onready var gradient_rect = $Background/GradientTexture

var current_gradient: Gradient
var word_count: int = 0
var base_hue: float = randf()

func _ready():
	current_gradient = Gradient.new()
	update_gradient()

func _on_text_text_changed():
	var new_word_count = text_edit.text.split(" ", false).size()
	if new_word_count != word_count:
		word_count = new_word_count
		update_gradient()

func update_gradient():
	if word_count < 1: return
	
	current_gradient.offsets = []
	current_gradient.colors = []
	
	for i in word_count + 1:
		var hue = fmod(base_hue + (0.1 * i), 1.0)
		var saturation = 0.5 + (i * 0.02)
		var value = 0.8 - (i * 0.01)
		current_gradient.add_point(float(i)/word_count, Color.from_hsv(hue, saturation, value))
	
	# Update the TextureRect's gradient texture
	var gradient_texture = gradient_rect.texture as GradientTexture2D
	gradient_texture.gradient = current_gradient

func save_entry():
	var entry = JournalEntry.new()
	entry.text = text_edit.text
	
	# Create enhanced gradient
	var final_gradient = current_gradient.duplicate()
	final_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	
	# Enhance colors
	var enhanced_colors = []
	for color in final_gradient.colors:
		enhanced_colors.append(Color.from_hsv(
			color.h,
			clamp(color.s * 1.2, 0, 1),
			clamp(color.v * 1.1, 0, 1)
		))
	
	final_gradient.colors = enhanced_colors
	
	# Save gradient data
	entry.gradient_colors = final_gradient.colors
	entry.gradient_offsets = final_gradient.offsets
	
	# Save to file
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	ResourceSaver.save(entry, "user://journal_entries/%s.res" % timestamp)
	clear_journal()

func clear_journal():
	text_edit.text = ""
	word_count = 0
	base_hue = randf()
	current_gradient = Gradient.new()
	update_gradient()
func _on_save_button_pressed() -> void:
	save_entry()
	pass # Replace with function body.


func _on_text_edit_text_changed() -> void:
	_on_text_text_changed()
	pass # Replace with function body.
