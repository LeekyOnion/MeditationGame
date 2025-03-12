extends CanvasLayer
class_name HUD

var main = load("res://levels/Main.tscn")

func _open_journal() -> void:
	main.journal_hud.visible = true
	main.hud.visible = false
