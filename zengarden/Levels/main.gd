extends Node2D
class_name Main

@onready var hud = $HUD
@onready var journal_hud = $JournalHUD
@onready var inventory_hud = $InventoryHUD
@onready var tile = %TileMap

func _ready() -> void:
	hud.main = self
	journal_hud.main = self
	inventory_hud.main = self

func _process(delta: float) -> void:
		#system time
	print(Global.month_year)
	$Label.text = Global.month_year
	pass

func spawn_draggable_sprite() -> void:
	pass
