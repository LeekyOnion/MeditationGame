extends CanvasLayer
class_name JournalHUD

var main = Main

func _close_journal() -> void:
	main.hud.visible = true
	main.journal_hud.visible = false
