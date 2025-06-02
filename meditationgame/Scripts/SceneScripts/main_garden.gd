extends Node
class_name Main_Garden


#References to different hud elements / screens and the grid map that decorations are placed on.
@onready var hud = $Hud
@onready var journal = $Journal
@onready var journal_hud = $Journal/Control
@onready var inventory_hud = $InventoryHUD
@onready var tile = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.main = self
	journal_hud.main = self
	inventory_hud.main = self
