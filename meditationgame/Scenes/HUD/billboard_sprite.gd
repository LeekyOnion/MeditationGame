extends Sprite3D
class_name BillboardSprite

# Since this script IS attached to Sprite3D, we reference self
@onready var sprite : Sprite3D = self

@export var _texture : Texture2D
@export var grid_map : GridMap

var selected = false
var mouse_offset = Vector3(0, 0, 0)
var tile_size = Vector3(0, 0, 0)
var input_event : InputEventMouseButton

const RAY_LENGTH := 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _texture != null: # and grid_map is null:
		sprite.texture = _texture
		# tile_size = grid_map.cell_size
		# scale = Vector3(0, 0, 0) # Changed when needed, just thought it was a fine size for now

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# Similar code to the raking. When holding right click on the billboard sprite, ...
