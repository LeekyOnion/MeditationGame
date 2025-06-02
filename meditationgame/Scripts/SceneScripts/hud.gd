extends CanvasLayer
class_name HUD

var main = Main_Garden

func _open_journal() -> void:
	main.journal.visible = true
	main.hud.visible = false

func _open_inventory() -> void:
	main.inventory_hud.visible = true
	main.hud.visible = false
