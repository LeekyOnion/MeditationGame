extends Node
class_name JournalInventorySelector

@export var game_manager : MainGameManager;

func _ready() -> void:
	if game_manager == null:
		push_error("HUD_Manager: Game Manager is not assigned!");
		return;
		
	if %Inventory  == null:
		push_error("Inventory not in scene.")
		return;
		
