extends Node3D
class_name MainGameManager

#region Signal Management
## JOURNAL SIGNALS
func _on_journal_journal_active() -> void:
	_disable_all_interactables_processes();
	
	%JournalGame.process_mode = Node.PROCESS_MODE_INHERIT;
	%JournalGame.set_visible(true);
	
	%ActiveNotification.get_node("%LineEdit").set_text("Journal Active")
	%ActiveNotification.set_visible(true);
	
func _on_journal_game_close_journal() -> void:
	_enable_all_interactables_processes();
	
	%JournalGame.process_mode = Node.PROCESS_MODE_DISABLED;
	%JournalGame.set_visible(false);
	
	%ActiveNotification.set_visible(false);
	
func _on_journal_game_save_journal() -> void:
	print("TODO: A reminder to implement the Save Journal feature...")

## RAKE SIGNALS
func _on_rake_active() -> void:
	_disable_all_interactables_processes();
	
	%RakeGame.process_mode = Node.PROCESS_MODE_INHERIT;
	%RakeGame.set_visible(true);
	
	%ActiveNotification.get_node("%LineEdit").set_text("Rake Active")
	%ActiveNotification.set_visible(true);
	
func _on_rake_game_exit() -> void:
	_enable_all_interactables_processes();
	
	%RakeGame.process_mode = Node.PROCESS_MODE_DISABLED;
	%RakeGame.set_visible(false);
	
	%ActiveNotification.set_visible(false);
	
## BREATHING GAME SIGNALS
func _on_singing_bowl_breathing_active() -> void:
	_disable_all_interactables_processes();
	
	%BreathingGame.process_mode = Node.PROCESS_MODE_INHERIT;
	%BreathingGame.set_visible(true);

	%ActiveNotification.get_node("%LineEdit").set_text("Breathing Active")
	%ActiveNotification.set_visible(true);
	
func _on_breathing_game_close_breathing() -> void:
	_enable_all_interactables_processes();
	
	%BreathingGame.process_mode = Node.PROCESS_MODE_DISABLED;
	%BreathingGame.set_visible(false);

## INVENTORY SIGNALS

func _on_inventory_manager_open() -> void:
	_disable_all_interactables_processes();
	
	%InventoryButton.process_mode = Node.PROCESS_MODE_DISABLED;
	%InventoryButton.set_visible(false);
	
	%InventoryManager.process_mode = Node.PROCESS_MODE_INHERIT;
	%InventoryManager.set_visible(true);
	
	%ActiveNotification.get_node("%LineEdit").set_text("Inventory Active")
	%ActiveNotification.set_visible(true);

func _on_inventory_manager_close_inventory() -> void:
	_enable_all_interactables_processes();
	
	%InventoryManager.process_mode = Node.PROCESS_MODE_DISABLED;
	%InventoryManager.set_visible(false);
	
	%ActiveNotification.set_visible(false);
	
	%InventoryButton.process_mode = Node.PROCESS_MODE_INHERIT;
	%InventoryButton.set_visible(true);
	
#endregion Signal Management

func _ready() -> void:
	_disable_all_activities_processes();
	%InventoryButton.set_visible(true);

func _enable_all_interactables_processes() -> void:
	for interactable in %Interactables.get_children():
		interactable.process_mode = Node.PROCESS_MODE_INHERIT;

func _disable_all_interactables_processes() -> void:
	for interactable in %Interactables.get_children():
		interactable.process_mode = Node.PROCESS_MODE_DISABLED;

func _disable_all_activities_processes() -> void:
	for activity in %Activities.get_children():
		activity.process_mode = Node.PROCESS_MODE_DISABLED;
