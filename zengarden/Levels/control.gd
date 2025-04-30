#this is just what we had for buttons on the main level

extends Control

# Paths to the buttons
@onready var new_game_button: Button = $VBoxContainer/NewGame
@onready var quit_button: Button = $VBoxContainer/Quit

func _ready():
	# Connect button signals to functions
	new_game_button.connect("pressed", Callable(self, "_on_new_game_button_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))

func _on_new_game_button_pressed():
	# Load the game scene and switch to it
	var game_scene = load("res://Levels/MainGarden.tscn")  # Replace with your game scene path
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
