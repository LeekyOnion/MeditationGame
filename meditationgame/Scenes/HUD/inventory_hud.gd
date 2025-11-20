extends CanvasLayer
class_name InventoryHUD

# ---------------------------
# Signals
# ---------------------------
signal item_selected(item_texture: Texture2D)
signal close_inventory

# ---------------------------
# Exports
# ---------------------------
@export var billboard_sprite: PackedScene         # Drag your Sprite3D scene here
@export var item_textures: Array[Texture2D] = [] # List of item textures
@export var button_scene: PackedScene            # Scene for inventory buttons

# ---------------------------
# Nodes
# ---------------------------
@onready var panel: GridContainer = $GridContainer
@onready var close_button: Button = $CloseButton

# Reference to Main_Garden
var main_garden: Main_Garden = null

# ---------------------------
# Initialization
# ---------------------------
func _ready() -> void:
	print("InventoryHUD: Ready. Generating item buttons...")
	_find_main_garden()
	_generate_item_buttons()
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	else:
		push_warning("InventoryHUD: CloseButton node not found!")

# ---------------------------
# Find Main_Garden node
# ---------------------------
func _find_main_garden() -> void:
	# Try getting parent first
	var parent = get_parent()
	if parent is Main_Garden:
		main_garden = parent as Main_Garden
		print("InventoryHUD: Found Main_Garden as direct parent")
		return
	
	# If not direct parent, search up the tree
	var current_node = get_parent()
	while current_node != null:
		if current_node is Main_Garden:
			main_garden = current_node as Main_Garden
			print("InventoryHUD: Found Main_Garden in tree")
			return
		current_node = current_node.get_parent()
	
	# Last resort: search the entire scene tree
	var root = get_tree().get_current_scene()
	if root is Main_Garden:
		main_garden = root as Main_Garden
		print("InventoryHUD: Found Main_Garden as scene root")
		return
	
	# Search children of root
	for child in root.get_children():
		if child is Main_Garden:
			main_garden = child as Main_Garden
			print("InventoryHUD: Found Main_Garden as child of root")
			return
	
	push_error("InventoryHUD: Could not find Main_Garden node!")

# ---------------------------
# Generate inventory buttons
# ---------------------------
func _generate_item_buttons() -> void:
	# Clear existing buttons
	for child in panel.get_children():
		child.queue_free()
	
	for texture in item_textures:
		if texture == null:
			push_warning("InventoryHUD: Found null texture, skipping.")
			continue
		
		var button = button_scene.instantiate() as TextureButton
		var texture_rect = button.get_node("TextureRect") as TextureRect
		texture_rect.texture = texture
		button.set_meta("item_texture", texture)
		button.pressed.connect(_on_item_button_pressed.bind(button))
		panel.add_child(button)
		print(" - Added button for:", texture.resource_path)

# ---------------------------
# Called when a button is clicked
# ---------------------------
func _on_item_button_pressed(button: TextureButton) -> void:
	var texture = button.get_meta("item_texture") as Texture2D
	if texture == null:
		push_error("InventoryHUD: Button missing texture!")
		return
	
	print("[DEBUG] InventoryHUD: Item selected:", texture.resource_path)
	
	# Just emit the signal - Main_Garden will handle the rest
	emit_signal("item_selected", texture)

# ---------------------------
# Close inventory button
# ---------------------------
func _on_close_pressed() -> void:
	print("InventoryHUD: Close pressed — emitting 'close_inventory' signal.")
	visible = false  # Hide ourselves directly
	emit_signal("close_inventory")
