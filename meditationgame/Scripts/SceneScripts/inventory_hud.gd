#Manages the inventory HUD and spawning in any decorations in the MainGarden scene.
extends CanvasLayer
class_name InventoryHUD

@export var billboard_sprite_scene : PackedScene

@onready var sprite_button = %SpriteButton

var main : MainGarden

func _select_item() -> void:
	#Pressing a decoration button on the inventory HUD will call this function through a signal,
	#instantiating a BillboardSprite and setting the billboard sprite's texture
	#to the same as the one set on the button.
	var billboard_sprite = billboard_sprite_scene.instantiate()
	billboard_sprite._texture = %SpriteButton.icon as Texture2D
	billboard_sprite.grid_map = main.tile #Passing in the MainGarden grid map to snap the billboard sprite's position to
	billboard_sprite.position = Vector3(64, 4, 64)
	self.get_parent().add_child(billboard_sprite)
	self.visible = false
	main.hud.visible = true

func _close_inventory() -> void:
	main.hud.visible = true
	main.inventory_hud.visible = false
