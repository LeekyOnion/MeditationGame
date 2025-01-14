extends Node2D
class_name Sprite

@onready var sprite = $Visual
@onready var collision = $Visual/Area2D/CollisionShape2D

@export var _texture : Texture2D
@export var tile_map : TileMapLayer

var selected = false
var mouse_offset = Vector2(0, 0)
var tile_size = Vector2(0, 0)

func _ready() -> void:
	if _texture != null and tile_map != null:
		sprite.texture = _texture
		tile_size = tile_map.tile_set.tile_size
	collision.shape.size = sprite.texture.get_size()

func _process(delta: float) -> void:
	if selected:
		followMouse()

func followMouse():
	var pos = get_global_mouse_position() + mouse_offset
	position = pos.snapped(Vector2(tile_size.x, tile_size.y))

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = position - get_global_mouse_position()
			selected = true
		else:
			selected = false
