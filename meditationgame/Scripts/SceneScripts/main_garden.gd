extends Node

class_name MainGarden


#References to different hud elements / screens and the grid map that decorations are placed on.
@onready var hud = $HUD
@onready var journal = $BenJournalScene
@onready var journal_hud = $BenJournalScene/Control
@onready var inventory_hud = $InventoryHUD
@onready var tile = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.main = self
	journal_hud.main = self
	inventory_hud.main = self
