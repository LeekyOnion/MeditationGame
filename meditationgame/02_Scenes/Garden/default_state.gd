extends State
class_name DefaultState

@export var game_manager : MainGameManager;

func Enter() -> void:
	game_manager.enable_all_interactables_processes();

func Exit() -> void:
	game_manager.disable_all_interactables_processes();

func Update(_delta : float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	pass
