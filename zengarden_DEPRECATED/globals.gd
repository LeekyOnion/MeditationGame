extends Node

#variables related to keeping track of the time in the real world to be used in the game
static var current_time = String(Time.get_datetime_string_from_system(false, true))
static var date_partition = current_time.split("T")[0]
static var sys_year = date_partition.split("-")[0]
static var sys_month = date_partition.split("-")[1]
static var month_year = sys_month + "/" + sys_year


# File path to save the last timestamp
const SAVE_PATH: String = "user://last_time_opened.cfg"

# Variables to store the last and current timestamps
var last_time_opened: int = 0

# word bank to be used when triggerin certain events in the journal
var word_bank = ["Tree", "bubbble", "Leaf"]

func _ready() -> void:
	# Load the last saved timestamp
	load_last_time_opened()
	
	print("User data directory: ", OS.get_user_data_dir())

	# Get the current time
	var current_time = Time.get_unix_time_from_system()

	# Calculate the time difference
	var time_passed: int = current_time - last_time_opened
	print("Time passed since last open: ", format_time_difference(time_passed))

	# Save the current time as the new "last opened" time
	save_last_time_opened(current_time)


#function to loat the time that the game was opened last
func load_last_time_opened() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		last_time_opened = config.get_value("timestamps", "last_time_opened", 0)
	else:
		print("No saved timestamp found. Using default value (0).")


#Save the last timethe game was opened to a file
func save_last_time_opened(current_time: int) -> void:
	var config = ConfigFile.new()
	config.set_value("timestamps", "last_time_opened", current_time)
	config.save(SAVE_PATH)


#function to format the time difference from last open to current open - this should be used to calculate whether certain things should happen to plants
func format_time_difference(seconds: int) -> String:
	var days: int = seconds / (24 * 60 * 60)
	seconds %= 24 * 60 * 60
	var hours: int = seconds / (60 * 60)
	seconds %= 60 * 60
	var minutes: int = seconds / 60
	seconds %= 60

	return "%d days, %d hours, %d minutes, %d seconds" % [days, hours, minutes, seconds]


func _notification(what: int) -> void:
	# Detect when the game is about to close
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_last_time_opened(Time.get_unix_time_from_system())
		get_tree().quit()
