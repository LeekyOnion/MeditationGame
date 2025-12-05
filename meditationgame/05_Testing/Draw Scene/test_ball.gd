extends Node3D

@export var animplayer : AnimationPlayer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animplayer.play("Ball Animation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
