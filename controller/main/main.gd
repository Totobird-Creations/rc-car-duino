extends Control



export(bool) var connected : bool = false setget set_connected

var touches : = {}



func set_connected(value : bool) -> void:
	connected = value
	if (get_node_or_null("disconnected/toggle")):
		if (connected):
			$disconnected/toggle.play_backwards("main")
			$disconnected/timer.start()
		else:
			$disconnected/toggle.play("main")



func _physics_process(delta : float):
	var accelerations := []
	var turns         := []
	for touch in touches.values():
		if (
			touch.x >= $control/acceleration.rect_global_position.x &&
			touch.y >= $control/acceleration.rect_global_position.y &&
			touch.x <= $control/acceleration.rect_global_position.x + $control/acceleration.rect_size.x &&
			touch.y <= $control/acceleration.rect_global_position.y + $control/acceleration.rect_size.y
		):
			accelerations.append((touch.y - $control/acceleration.rect_global_position.y) / $control/acceleration.rect_size.y)
		elif (
			touch.x >= $control/turn.rect_global_position.x &&
			touch.y >= $control/turn.rect_global_position.y &&
			touch.x <= $control/turn.rect_global_position.x + $control/turn.rect_size.x &&
			touch.y <= $control/turn.rect_global_position.y + $control/turn.rect_size.y
		):
			turns.append((touch.x - $control/turn.rect_global_position.x) / $control/turn.rect_size.x)

	var final_acceleration := 0.5
	var final_turn         := 0.5

	if (connected):
		if (len(accelerations) > 0):
			final_acceleration = 0.0
			for acceleration in accelerations:
				final_acceleration += acceleration
			final_acceleration /= len(accelerations)
		if (len(turns) > 0):
			final_turn = 0.0
			for turn in turns:
				final_turn += turn
			final_turn /= len(turns)

	var previous := $control/acceleration/background.material.get_shader_param("position") as Vector2
	var target   := Vector2(final_turn, final_acceleration)
	var current  := previous.move_toward(target, previous.distance_to(target) * delta * 15.0)

	$control/acceleration/background.material.set_shader_param("position", current)
	$control/info/background.material.set_shader_param("position", current)
	$control/turn/background.material.set_shader_param("position", current)



func _input(event : InputEvent) -> void:
	if (event is InputEventScreenTouch):
		if (event.pressed):
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

	elif (event is InputEventScreenDrag):
		touches[event.index] = event.position



func attempt_connect():
	set_connected(true)
