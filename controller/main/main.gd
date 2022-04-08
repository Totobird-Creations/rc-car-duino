extends Control



const LOG_LINE : PackedScene = preload('res://main/log_line.tscn')



enum State {
	Disconnected,
	Connecting,
	Connected
}
export(int, 'Disconnected', 'Connecting', 'Connected') var state : int = State.Disconnected setget set_state

var touches : = {}



func set_state(value : int) -> void:
	if (get_node_or_null("disconnected")):
		if (state == State.Disconnected && value == State.Connecting):
			$disconnected/connect/toggle.play("main")
			$disconnected/connect/timer.start()
			$connector.connecting = true
		elif (state == State.Connecting && value == State.Disconnected):
			$disconnected/connect/toggle.play_backwards("main")
			$disconnected/connect/timer.stop()
			$connector.connecting = false
		elif (state == State.Connecting && value == State.Connected):
			$disconnected/connect/toggle.play_backwards("main")
			$disconnected/toggle.play_backwards("main")
			$disconnected/connect/timer.stop()
			$connector.connecting = false
		elif (state == State.Connected && value == State.Disconnected):
			$disconnected/toggle.play("main")
	state = value

func attempt_connect() -> void:
	add_log("Connecting...")
	set_state(State.Connecting)

func attempt_connect_timeout() -> void:
	add_log("Connection Timout")
	set_state(State.Disconnected)

func connected() -> void:
	add_log("Connection Established")
	set_state(State.Connected)

func connection_lost() -> void:
	add_log("Connection Lost")

func disconnected() -> void:
	add_log("Disconnected")
	set_state(State.Disconnected)



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

	if (state == State.Connected):
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



func add_log(text : String) -> void:
	var max_logs := 10
	var instance := LOG_LINE.instance()
	instance.set_text(text)
	$control/info/log.add_child(instance)
	if ($control/info/log.get_child_count() > max_logs):
		for i in range($control/info/log.get_child_count() - max_logs):
			$control/info/log.get_child(i).hide()
