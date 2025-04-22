extends CanvasLayer
class_name InventoryHUD

@export var draggable_sprite_scene : PackedScene

@onready var sprite_button = %SpriteButton

var main : MainGarden

func _select_item() -> void:
	var draggable_sprite = draggable_sprite_scene.instantiate()
	draggable_sprite._texture = %SpriteButton.icon as Texture2D
	draggable_sprite.tile_map = main.tile
	draggable_sprite.position = Vector2(0, 0)
	self.get_parent().add_child(draggable_sprite)
	self.visible = false

func _close_inventory() -> void:
	main.hud.visible = true
	main.inventory_hud.visible = false
