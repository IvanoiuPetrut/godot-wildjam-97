shader_type canvas_item;

// Full-screen damage feedback: vignette + chromatic aberration.
// Drive `intensity` from 0.0 (full health) to 1.0 (dead).

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.35, 0.0, 0.02, 1.0);
// Where the darkening starts, at full health and at death.
uniform float vignette_inner : hint_range(0.0, 1.5) = 0.95;
uniform float vignette_inner_hurt : hint_range(0.0, 1.5) = 0.15;
uniform float vignette_outer : hint_range(0.0, 2.0) = 1.45;
// How dark the vignette already is when untouched.
uniform float vignette_base : hint_range(0.0, 1.0) = 0.25;
uniform float aberration : hint_range(0.0, 0.05) = 0.012;
uniform float pulse_speed = 4.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec2 centered = SCREEN_UV - 0.5;
	// 0.0 at the centre, ~1.0 at the corners.
	float dist = length(centered) * 1.414;

	// Heartbeat: only pulses once you are actually hurt.
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount * intensity;
	float amount = clamp(intensity * pulse, 0.0, 1.0);

	// Split the channels outward from the centre; nothing shifts at dead centre
	// so the crosshair area stays readable.
	vec2 offset = centered * dist * aberration * amount;
	vec3 col;
	col.r = texture(screen_texture, SCREEN_UV + offset).r;
	col.g = texture(screen_texture, SCREEN_UV).g;
	col.b = texture(screen_texture, SCREEN_UV - offset).b;

	// Vignette closes in as health drops.
	float inner = mix(vignette_inner, vignette_inner_hurt, amount);
	float v = smoothstep(inner, vignette_outer, dist);
	col = mix(col, vignette_color.rgb, v * mix(vignette_base, 1.0, amount));

	COLOR = vec4(col, 1.0);
}
