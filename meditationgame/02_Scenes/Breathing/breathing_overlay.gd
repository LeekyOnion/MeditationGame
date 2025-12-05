extends Control

var max_radius = 100.0
var min_radius = 50.0
var speed = 2.0
var growing = true
var success_tolerance = 5.0
var success_count = 0

var _radius = 50.0  # starting radius

@onready var breath_label = $BreathLabel
@onready var counter_label = $CounterLabel

var tween: Tween

func _ready():
	var center = get_size() / 2
	breath_label.position = center + Vector2(0, max_radius + 30)
	counter_label.position = center + Vector2(0, max_radius + 60)
	
	animate_circle()

func _draw():
	var center = get_size() / 2
	# Animated circle - bigger one
	draw_circle(center, _radius, Color(0.3, 0.6, 1.0, 0.5))
	# Static smaller circle on top (draw last so it’s top layer)
	draw_circle(center, min_radius, Color(0.2, 0.4, 0.8, 1.0))

func animate_circle():
	var target_radius = max_radius if growing else min_radius
	breath_label.text = "Inhale" if growing else "Exhale"
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "_radius", target_radius, speed)
	tween.tween_callback(Callable(self, "_on_tween_finished"))

func _on_tween_finished():
	growing = not growing
	animate_circle()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if abs(_radius - min_radius) <= success_tolerance:
			success_count += 1
			counter_label.text = "Successes: %d" % success_count

func _set(property: StringName, value) -> bool:
	if property == "_radius":
		_radius = value
		queue_redraw()
		return true
	return false

func _get(property: StringName):
	if property == "_radius":
		return _radius
	return null

func _on_exit_button_pressed():
	queue_free()
