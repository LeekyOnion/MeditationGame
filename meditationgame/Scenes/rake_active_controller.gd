extends CanvasLayer
class_name RakeActive

@export var RakeObject : RakeController

func _ready() -> void:
	RakeObject.rake_active.connect(_set_visibility)

func _process(delta: float) -> void:
	pass

func _set_visibility() -> void:
	if self.visible:
		self.visible = false
		print("HUD changed to visible")
		
	elif not self.visible:
		self.visible = true
		print("HUD changed to not visible")
