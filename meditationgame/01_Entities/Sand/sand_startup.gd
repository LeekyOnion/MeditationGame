extends Node3D
@export var sand                 : MeshInstance3D
@export var sand_colorRect       : ColorRect
@export var sand_viewport        : SubViewport
@export var collision_viewport   : SubViewport # COLLISION

@onready var sand_tex = sand_viewport.get_texture()
@onready var col_tex  = collision_viewport.get_texture()

func _ready():
	sand.mesh.surface_get_material(0).set_shader_parameter('sand', sand_tex)

func _process(_delta):
	pass
