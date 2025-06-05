extends Control
class_name Main_Menu_Controls

#region VARIABLES
# Paths to the buttons
@export var new_game_button : Button 
@export var quit_button     : Button
#endregion VARIABLES
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game_button.connect("pressed", Callable(self, "_on_new_game_button_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))

func _on_new_game_button_pressed():
	# Load the game scene and switch to it
	var game_scene = load("res://Scenes/Main_Garden.tscn")  # Replace with your game scene path
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
