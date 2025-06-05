extends Node
class_name HUD_Manager

@export var main : Main_Garden

func _open_journal() -> void:   # Signal comes from Journal Button
	main.journal.visible = true
	main.hud.visible     = false

func _open_inventory() -> void: # Signal comes from Inventory Button
	main.Inventory_hud.visible = true
	main.hud.visible           = false

# SIGNAL LISTENERS
func _on_journal_close() -> void: # Make sure to hook this up when placing in the Main Scene
	main.hud.visible = true
	main.journal.visible = false
