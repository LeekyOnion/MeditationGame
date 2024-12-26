extends Sprite2D

#Function to detect mouse input on a sprite
#-	Would either be used to pull up a menu on choices you can make with a plant
#-	Or could be determined by a tool you are holding in your hand.
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			print("You Clicked on This Sprite")
