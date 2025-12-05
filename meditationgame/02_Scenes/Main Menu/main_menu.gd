extends Control
class_name MainMenu

#region VARIABLES

@export var starting_game_scene : PackedScene
@export var new_game_button : Button 
@export var quit_button     : Button

#endregion VARIABLES
func _ready() -> void:
	new_game_button.connect("pressed", Callable(self, "_on_new_game_button_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))

func _on_new_game_button_pressed():
	get_tree().change_scene_to_packed(starting_game_scene)

func _on_quit_button_pressed():
	get_tree().quit()
