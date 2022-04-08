extends Control



var hidden : bool = false



func set_text(value : String) -> void:
	$text.text = value



func hide() -> void:
	if (! hidden):
		hidden = true
		$animation.play("hide")
