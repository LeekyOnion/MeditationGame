extends CanvasLayer
class_name InventoryHUD

@export var billboard_sprite_scene : PackedScene

@onready var sprite_button = %SpriteButton

var main : MainGarden

func _select_item() -> void:
	var billboard_sprite = billboard_sprite_scene.instantiate()
	billboard_sprite._texture = %SpriteButton.icon as Texture2D
	billboard_sprite.grid_map = main.tile
	billboard_sprite.position = Vector3(64, 4, 64)
	self.get_parent().add_child(billboard_sprite)
	self.visible = false
	main.hud.visible = true

func _close_inventory() -> void:
	main.hud.visible = true
	main.inventory_hud.visible = false
