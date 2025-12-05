extends Sprite3D
class_name BillboardSprite

@onready var sprite : Sprite3D = self

@export var _texture : Texture2D
@export var grid_map : GridMap

var selected = false
var mouse_offset = Vector3(0, 0, 0)
var tile_size = Vector3(0, 0, 0)
var input_event : InputEventMouseButton

const RAY_LENGTH := 1000

func _ready() -> void:
	if _texture != null:
		sprite.texture = _texture


func _process(delta: float) -> void:
	pass
