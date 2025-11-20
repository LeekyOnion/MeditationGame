extends Node
class_name HUD_Manager

@export var main : Main_Garden

func _ready() -> void:
	# Validate all required references on startup
	if main == null:
		push_error("HUD_Manager: main (Main_Garden) is not assigned!")
		return
	
	if main.journal == null:
		push_warning("HUD_Manager: main.journal is not assigned!")
	
	if main.hud == null:
		push_warning("HUD_Manager: main.hud is not assigned!")
	
	if main.inventory_hud == null:
		push_warning("HUD_Manager: main.inventory_hud is not assigned!")

func _open_journal() -> void:   # Signal comes from Journal Button
	if main == null:
		push_error("HUD_Manager: main is null")
		return
	
	if main.journal:
		main.journal.visible = true
	else:
		push_error("HUD_Manager: main.journal is null, cannot open journal")
	
	if main.hud:
		main.hud.visible = false
	else:
		push_warning("HUD_Manager: main.hud is null")

func _open_inventory() -> void: # Signal comes from Inventory Button
	if main == null:
		push_error("HUD_Manager: main is null")
		return
	
	if main.inventory_hud:
		main.inventory_hud.visible = true
	else:
		push_error("HUD_Manager: main.inventory_hud is null, cannot open inventory")
	
	if main.hud:
		main.hud.visible = false
	else:
		push_warning("HUD_Manager: main.hud is null")

# SIGNAL LISTENERS
func _on_journal_close() -> void: # Make sure to hook this up when placing in the Main Scene
	if main == null:
		push_error("HUD_Manager: main is null")
		return
	
	if main.hud:
		main.hud.visible = true
	else:
		push_warning("HUD_Manager: main.hud is null")
	
	if main.journal:
		main.journal.visible = false
	else:
		push_warning("HUD_Manager: main.journal is null")
