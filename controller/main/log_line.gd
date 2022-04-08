extends Control



var hidden : bool = false



func set_text(value : String) -> void:
	$text.text = value

func set_icon(value : String) -> void:
	$icon.text = value

func set_colour(value : Color) -> void:
	$text.modulate = value
	$icon.modulate = value



func hide() -> void:
	if (! hidden):
		hidden = true
		$animation.play("hide")
