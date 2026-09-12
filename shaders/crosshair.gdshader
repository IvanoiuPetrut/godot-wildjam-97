shader_type canvas_item;
// Exposes these values to the Godot Inspector and your GDScript
uniform float fire_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.2, 0.2, 1.0); // Defaults to red

void fragment() {
	// Shift UVs to center them, scale them based on intensity, and shift them back.
	// This creates a "recoil" expansion effect.
	vec2 centered_uv = UV - 0.5;
	vec2 recoiled_uv = centered_uv * (1.0 - (fire_intensity * 0.3)) + 0.5;
	
	// Sample the texture using the new recoiled UVs
	vec4 tex_color = texture(TEXTURE, recoiled_uv);
	
	// Mix the base texture color with the flash color based on intensity
	vec3 blended_color = mix(tex_color.rgb, flash_color.rgb, fire_intensity);
	
	// Output the final color, keeping the texture's original transparency
	COLOR = vec4(blended_color, tex_color.a);
}