extends CanvasLayer
class_name InventoryController

signal inventory_open;

func _open_inventory() -> void:
	inventory_open.emit();
