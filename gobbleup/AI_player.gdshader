shader_type spatial;

// This render mode IS valid in a spatial shader and will fix the billboarding.
render_mode billboard_keep_scale, unshaded;

// A uniform for the sprite's texture, which we'll link in the material.
uniform sampler2D sprite_texture : source_color, filter_nearest;

// The slider to control the tint strength.
uniform float white_tint_amount : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	// Get the original color from the texture uniform.
	vec4 original_color = texture(sprite_texture, UV);
	
	// Make the tint respect transparency.
	float tint_strength = white_tint_amount * original_color.a;
	
	// Mix the original color with white.
	vec3 tinted_rgb = mix(original_color.rgb, vec3(1.0), tint_strength);
	
	// Assign the final color to the 3D render channels.
	ALBEDO = tinted_rgb;
	ALPHA = original_color.a;
}