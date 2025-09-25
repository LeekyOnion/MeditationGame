extends CanvasLayer
class_name InventoryHUD

@export var billboard_sprite_scene: PackedScene
@export var item_textures: Array[Texture2D] = []
@export var button_scene: PackedScene

@onready var panel: GridContainer = $GridContainer
@onready var close_button: Button = $CloseButton

signal item_selected(item_texture: Texture2D)

func _ready() -> void:
	_generate_item_buttons()
	if close_button != null:
		close_button.pressed.connect(Callable(self, "_on_close_pressed"))
	else:
		push_warning("CloseButton node not found!")

func _generate_item_buttons() -> void:
	# Remove existing buttons
	for child in panel.get_children():
		child.queue_free()

	for texture in item_textures:
		var button = button_scene.instantiate() as TextureButton

		# Assign texture to TextureRect child (handles all scaling)
		var texture_rect = button.get_node("TextureRect") as TextureRect
		texture_rect.texture = texture

		button.set_meta("item_texture", texture)
		button.pressed.connect(Callable(self, "_on_item_button_pressed").bind(button))

		panel.add_child(button)

func _on_item_button_pressed(button: TextureButton) -> void:
	var texture = button.get_meta("item_texture") as Texture2D
	if billboard_sprite_scene != null:
		var billboard_sprite = billboard_sprite_scene.instantiate()
		billboard_sprite.texture = texture
	emit_signal("item_selected", texture)
	self.visible = false

func _on_close_pressed() -> void:
	self.visible = false
