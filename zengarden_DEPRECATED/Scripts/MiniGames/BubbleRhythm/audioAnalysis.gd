extends Node

@export var audio_stream: AudioStream
@onready var audio_player = $AudioStreamPlayer
var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance
var previous_energy = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var effect = AudioEffectSpectrumAnalyzer.new()
	audio_player.add_effect(effect)
	spectrum_analyzer = audio_player.get_effect_instance(0)

var bubble_scene = preload("res://Scenes/bubble.tscn")
var spawn_radius = 500.0
var spawn_cooldown = 0.1
var last_spawn_time = 0.0

func _process(delta: float) -> void:
	if audio_player.playing:
		var current_energy = get_energy()
		if current_energy - previous_energy > 0.5 && Time.get_ticks_msec() - last_spawn_time > spawn_cooldown * 1000:
			spawn_bubble()
			previous_energy = current_energy
			last_spawn_time = Time.get_ticks_msec()

func get_energy() -> float:
	return spectrum_analyzer.get_magnitude_for_frequency_range(0,200).length()


var beat_delay = 0.5
func spawn_bubble():
	var bubble = bubble_scene.instanntiate()
	var angle = randf_range(0, 2 * PI)
	var spawn_pos = Vector2(cos(angle), sin(angle)) * spawn_radius
	bubble.position = get_viewport().get_visible_rect().size / 2 + spawn_pos
	add_child(bubble)
	bubble.life_time = beat_delay
	bubble.speed = (bubble.target_position - bubble.position).length() / beat_delay
