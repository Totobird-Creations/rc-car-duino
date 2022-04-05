extends Control



var touches : Dictionary = {}



func _physics_process(delta : float):
	pass



func _input(event : InputEvent) -> void:
	if (event is InputEventScreenTouch):
		if (event.pressed):
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

	elif (event is InputEventScreenDrag):
		touches[event.index] = event.position
