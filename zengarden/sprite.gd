extends Node2D
class_name Sprite

@onready var sprite = $Visual
@onready var collision = $Visual/Area2D/CollisionShape2D

@export var _texture : Texture2D

var selected = false
var mouse_offset = Vector2(0, 0)

func _ready() -> void:
	if _texture != null:
		sprite.texture = _texture
	collision.shape.size = sprite.texture.get_size()

func _process(delta: float) -> void:
	if selected:
		followMouse()

func followMouse():
	position = get_global_mouse_position() + mouse_offset

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = position - get_global_mouse_position()
			selected = true
		else:
			selected = false
