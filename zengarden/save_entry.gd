extends Control

# Path to the TextEdit, Button, and RichTextLabel nodes
@onready var entry_text_edit: TextEdit = $VBoxContainer/TextEdit
@onready var save_button: Button = $VBoxContainer/Save
@onready var journal_display: RichTextLabel = $VBoxContainer/RichTextLabel

# Array to store journal entries
var journal_entries: Array = []

func _ready():
	# Connect the button's pressed signal to a function
	save_button.connect("pressed", Callable(self, "_on_save_button_pressed"))

func _on_save_button_pressed():
	# Get the text from the TextEdit
	var entry_text = entry_text_edit.text

	# Add the entry to the journal
	if entry_text.strip_edges() != "":
		journal_entries.append(entry_text)
		update_journal_display()
		entry_text_edit.text = ""  # Clear the TextEdit after saving

func update_journal_display():
	# Clear the RichTextLabel and display all entries
	journal_display.text = ""
	for entry in journal_entries:
		journal_display.text += "• " + entry + "\n\n"
		
		
func save_journal():
	var file = FileAccess.open("user://journal.save", FileAccess.WRITE)
	if file:
		file.store_var(journal_entries)
		file.close()
		
		
func load_journal():
	if FileAccess.file_exists("user://journal.save"):
		var file = FileAccess.open("user://journal.save", FileAccess.READ)
		if file:
			journal_entries = file.get_var()
			file.close()
			update_journal_display()
