shader_type canvas_item;



uniform vec4 background : hint_color = vec4(vec3(0.1), 1.0);
uniform vec4 accent     : hint_color = vec4(vec3(0.0, 1.0, 0.0), 1.0);

uniform vec2 position                = vec2(0.5, 0.5);



vec4 interpolate(vec4 a, vec4 b, float t) {
	return a + (b - a) * clamp(t, 0.0, 1.0);
}



void fragment() {
	COLOR = interpolate(
		background,
		accent,
		max(
			pow(1.0 - distance(UV, position) * 5.0, 5.0) * 1.5,
			pow(1.0 - abs(UV.y - position.y) * 3.0, 50.0)
		)
	);
}
