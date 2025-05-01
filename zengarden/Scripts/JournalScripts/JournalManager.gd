#this script is the journal, the journal is meant to be a mechanic in which you type out some things going on, and there would be visual feedback to 
#what you are going to type. This prototype uses color gradients for every space in between a collection of character(s)
# and also pops bubbles onto the screen. Ideally, you want assets to make a complete image with some trigger words that will trigger specific feedback. 

#extends Control
#
#@onready var text_edit = $TextEdit
#@onready var gradient_rect = $Background/GradientTexture
#
#var current_gradient: Gradient
#var word_count: int = 0
#var base_hue: float = randf()
#
#func _ready():
	#current_gradient = Gradient.new()
	#update_gradient()
#
#func _on_text_text_changed():
	#var new_word_count = text_edit.text.split(" ", false).size()
	#if new_word_count != word_count:
		#word_count = new_word_count
		#update_gradient()
#
#func update_gradient():
	#if word_count < 1: return
	#
	#current_gradient.offsets = []
	#current_gradient.colors = []
	#
	#for i in word_count + 1:
		#var hue = fmod(base_hue + (0.1 * i), 1.0)
		#var saturation = 0.5 + (i * 0.02)
		#var value = 0.8 - (i * 0.01)
		#current_gradient.add_point(float(i)/word_count, Color.from_hsv(hue, saturation, value))
	#
	## Update the TextureRect's gradient texture
	#var gradient_texture = gradient_rect.texture as GradientTexture2D
	#gradient_texture.gradient = current_gradient
#
#func save_entry():
	#var entry = JournalEntry.new()
	#entry.text = text_edit.text
	#
	## Create enhanced gradient
	#var final_gradient = current_gradient.duplicate()
	#final_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	#
	## Enhance colors
	#var enhanced_colors = []
	#for color in final_gradient.colors:
		#enhanced_colors.append(Color.from_hsv(
			#color.h,
			#clamp(color.s * 1.2, 0, 1),
			#clamp(color.v * 1.1, 0, 1)
		#))
	#
	#final_gradient.colors = enhanced_colors
	#
	## Save gradient data
	#entry.gradient_colors = final_gradient.colors
	#entry.gradient_offsets = final_gradient.offsets
	#
	## Save to file
	#var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	#ResourceSaver.save(entry, "user://journal_entries/%s.res" % timestamp)
	#clear_journal()
#
#func clear_journal():
	#text_edit.text = ""
	#word_count = 0
	#base_hue = randf()
	#current_gradient = Gradient.new()
	#update_gradient()

extends Control

@onready var text_edit = $TextEdit
@onready var background = $Background  # Should be a ColorRect/Control node
@onready var gradient_rect = $Background/GradientTexture

var main = MainGarden

var current_gradient: Gradient
var word_count: int = 0
var base_hue: float = randf()
# Load a simple circle texture (create one in your project)
var splotch_texture = preload("res://circle.png")

func _ready():
	current_gradient = Gradient.new()
	update_gradient()

func _on_text_text_changed():
	var new_word_count = text_edit.text.split(" ", false).size()
	if new_word_count > word_count:
		var words_added = new_word_count - word_count
		for i in words_added:
			add_color_splotch()
	word_count = new_word_count
	update_gradient()

func add_color_splotch():
	# Create splotch instance
	var splotch = TextureRect.new()
	splotch.texture = splotch_texture
	splotch.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	splotch.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Random properties
	var base_color = Color.from_hsv(randf(), randf_range(0.5, 0.8), randf_range(0.7, 1.0))
	var target_color = base_color
	target_color.a = 0.0  # Fully transparent
	
	splotch.modulate = base_color
	splotch.position = Vector2(
		randf_range(0, background.size.x),
		randf_range(0, background.size.y)
	)
	splotch.size = Vector2(50, 50) * randf_range(0.5, 2.0)
	
	# Add to background
	background.add_child(splotch)
	
	# Create fade animation
	var tween = create_tween().set_parallel(true)
	#tween.tween_property(splotch, "modulate", target_color, 1.5)
	tween.tween_property(splotch, "scale", Vector2(3, 3), 1.5).set_trans(Tween.TRANS_BACK)
	#tween.tween_callback(splotch.queue_free).set_delay(1.5)
	
	#function to update the gradient for every word
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
	var final_gradient = current_gradient.duplicate()
	final_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC

	
	var enhanced_colors = []
	for color in final_gradient.colors:
		enhanced_colors.append(Color.from_hsv(
			color.h,
			clamp(color.s * 1.2, 0, 1),
			clamp(color.v * 1.1, 0, 1)
		))

	final_gradient.colors = enhanced_colors
	entry.gradient_colors = final_gradient.colors
	entry.gradient_offsets = final_gradient.offsets		
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	ResourceSaver.save(entry, "user://journal_entries/%s.res" % timestamp)
	clear_journal()

func clear_journal():
	text_edit.text = ""
	word_count = 0	
	base_hue = randf()
	current_gradient = Gradient.new()
	update_gradient()
	# Clear existing splotches
	for child in background.get_children():
		if child is TextureRect:
			child.queue_free()


func _on_save_button_pressed() -> void:
	save_entry()
	pass # Replace with function body.


func _on_text_edit_text_changed() -> void:
	_on_text_text_changed()
	pass # Replace with function body.
# Rest of your existing button handlers...

func _close_journal() -> void:
	main.hud.visible = true
	main.journal.visible = false
