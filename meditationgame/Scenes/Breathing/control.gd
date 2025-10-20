extends Control

# Circle animation properties
var max_radius := 200.0
var min_radius := 100.0
var speed := 2.0
var growing := true
var success_tolerance := 5.0
var success_count := 0

# Circle size
var _radius := 50.0

# UI elements
@onready var breath_label = $BreathLabel
@onready var counter_label = $CounterLabel
@onready var exit_button = $Button


# Tween reference
var tween: Tween

func _ready():
	size = get_viewport_rect().size
	var center = size / 2



# Center breath_label using anchors and offsets
	breath_label.anchor_left = 0.5
	breath_label.anchor_top = 0.5
	breath_label.anchor_right = 0.5
	breath_label.anchor_bottom = 0.5

	breath_label.offset_left = -breath_label.size.x / 2
	breath_label.offset_top = -breath_label.size.y / 2
	breath_label.offset_right = breath_label.size.x / 2
	breath_label.offset_bottom = breath_label.size.y / 2

# Center text inside the label
	breath_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	breath_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


	# Keep counter label underneath
	counter_label.position = center + Vector2(-40, max_radius + 20)
	
	exit_button.anchor_left = 1.0
	exit_button.anchor_top = 1.0
	exit_button.anchor_right = 1.0
	exit_button.anchor_bottom = 1.0

	exit_button.offset_left = -exit_button.size.x - 10
	exit_button.offset_top = -exit_button.size.y - 10
	exit_button.offset_right = -10
	exit_button.offset_bottom = -10

	animate_circle()


func _draw():
	var center = size / 2
	draw_circle(center, _radius, Color(0.3, 0.6, 1.0, 0.5))
	draw_circle(center, min_radius, Color(0.2, 0.4, 0.8, 1.0))

func animate_circle():
	var target_radius = max_radius if growing else min_radius
	breath_label.text = "Inhale" if growing else "Exhale"
	
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_method(Callable(self, "_set_radius"), _radius, target_radius, speed)
	tween.tween_callback(Callable(self, "_on_tween_finished"))

func _set_radius(value):
	_radius = value
	queue_redraw()

func _on_tween_finished():
	growing = not growing
	animate_circle()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if abs(_radius - min_radius) <= success_tolerance:
			success_count += 1
			counter_label.text = "Successes: %d" % success_count

func _on_button_pressed() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/Objects/Garden/Main_Garden.tscn")
