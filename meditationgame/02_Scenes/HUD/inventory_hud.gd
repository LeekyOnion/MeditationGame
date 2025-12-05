extends CanvasLayer
class_name InventoryHUD

## Variables
signal item_selected(item_texture: Texture2D)
signal close_inventory

@onready var panel: GridContainer = $GridContainer
@onready var close_button: Button = $CloseButton

@export var item_list : Array[PackedScene] = []
	
func _ready() -> void:
	print("InventoryHUD: Ready. Generating item buttons...")
	
	_connect_signals_to_buttons()
	close_button.pressed.connect(_on_close_pressed)
		
func _add_images_to_buttons() -> void:
	for i in panel.get_child_count():
		##TODO: Assign the TextureButton a Texture
		print(panel.get_child(i), " has been assigned texture ", item_list[i].get_meta("item_texture"))
		
## Signal Function
func _on_item_button_pressed() -> void:
	emit_signal("item_selected")
	
func _connect_signals_to_buttons() -> void:
	for button in panel.get_children():
		if not button.pressed.is_connected(_on_item_button_pressed):
			button.pressed.connect(_on_item_button_pressed)

func _disconnect_signals_from_buttons() -> void:
	for button in panel.get_children():
		if button.pressed.is_connected(_on_item_button_pressed):
			button.pressed.disconnect(_on_item_button_pressed)
		
func _on_close_pressed() -> void:
	#print("InventoryHUD: Close pressed — emitting 'close_inventory' signal.")
	visible = false
	
	emit_signal("close_inventory")
	
	#_disconnect_signals_from_buttons();
	#close_button.pressed.disconnect(_on_close_pressed)
	
