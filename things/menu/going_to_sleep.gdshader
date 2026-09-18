shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 0.4;
uniform float frequency : hint_range(0.0, 30.0) = 6.0;
uniform float amplitude : hint_range(0.0, 0.5) = 0.06;

void fragment() {
	float wave = sin((UV.x + UV.y) * frequency + TIME * speed);
	wave += sin((UV.x - UV.y) * frequency * 1.7 - TIME * speed * 1.3) * 0.5;
	COLOR.rgb += wave * amplitude;
}
