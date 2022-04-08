extends Control



const LOG_LINE : PackedScene = preload('res://main/log_line.tscn')

const COLOUR_INFO      : Color = Color(1.0, 0.75, 0.0)
const COLOUR_CONNECTED : Color = Color(0.0, 1.0, 0.25)
const COLOUR_ERROR     : Color = Color(1.0, 0.0, 0.25)
const COLOUR_DEBUG     : Color = Color(0.5, 0.5, 0.5)



enum State {
	Disconnected,
	Connecting,
	Connected
}
export(int, 'Disconnected', 'Connecting', 'Connected') var state : int = State.Disconnected setget set_state

var touches   := {}



func set_state(value : int) -> void:
	if (get_node_or_null("disconnected")):
		if (state == State.Disconnected && value == State.Connecting):
			add_log("*", "Connecting...", COLOUR_INFO)
			$disconnected/connect/toggle.play("main")
			$disconnected/connect/timer.start()
			if ($connector.script.library.get_current_library_path() != ""):
				$connector.connecting = true
		elif (state == State.Connecting && value == State.Disconnected):
			add_log("x", "Connection Timeout", COLOUR_ERROR)
			$disconnected/connect/toggle.play_backwards("main")
			$disconnected/connect/timer.stop()
			if ($connector.script.library.get_current_library_path() != ""):
				$connector.connecting = false
		elif (state == State.Connecting && value == State.Connected):
			add_log("+", "Connection Established", COLOUR_CONNECTED)
			$disconnected/connect/toggle.play_backwards("main")
			$disconnected/toggle.play_backwards("main")
			$disconnected/connect/timer.stop()
			if ($connector.script.library.get_current_library_path() != ""):
				$connector.connecting = false
		elif (state == State.Connected && value == State.Disconnected):
			add_log("-", "Disconnected", COLOUR_INFO)
			$disconnected/toggle.play("main")
	state = value

func attempt_connect() -> void:
	set_state(State.Connecting)

func attempt_connect_timeout() -> void:
	set_state(State.Disconnected)

func connected() -> void:
	set_state(State.Connected)

func connection_lost() -> void:
	add_log("x", "Connection Lost", COLOUR_ERROR)
	set_state(State.Disconnected)

func disconnected() -> void:
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



func add_log(icon : String, text : String, colour : Color) -> void:
	var max_logs := 10
	var instance := LOG_LINE.instance()
	instance.set_text(text)
	instance.set_icon(icon)
	instance.set_colour(colour)
	$control/info/log.add_child(instance)
	if ($control/info/log.get_child_count() > max_logs):
		for i in range($control/info/log.get_child_count() - max_logs):
			$control/info/log.get_child(i).hide()
