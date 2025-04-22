extends Node
class_name MainGarden

@onready var hud = $HUD
@onready var journal_hud = $JournalHUD
@onready var inventory_hud = $InventoryHUD
@onready var tile = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.main = self
	journal_hud.main = self
	inventory_hud.main = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
