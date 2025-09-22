// palette_dither.gdshader
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// --- NEW: A slider to control what's considered a shadow ---
uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.1;

// The palette is unchanged (16 colors). The first color is used for shadows.
const vec3 PALETTE[16] = vec3[](
	vec3(0.0, 0.0, 0.0),                      // Black (Shadow Color)
	vec3(0.180, 0.145, 0.169),                  // Dark Brown
	vec3(0.306, 0.145, 0.133),                  // Rich Brown
	vec3(0.784, 0.0, 0.149),                   // Red
	vec3(0.898, 0.349, 0.0),                   // Orange
	vec3(0.898, 0.722, 0.294),                  // Yellow
	vec3(1.0, 0.761, 0.0),                     // Bright Yellow
	vec3(0.220, 0.412, 0.220),                  // Forest Green
	vec3(0.588, 0.647, 0.0),                   // Lime Green
	vec3(0.412, 0.416, 0.541),                  // Slate Blue
	vec3(0.451, 0.647, 0.839),                  // Sky Blue
	vec3(0.969, 0.922, 0.824),                  // Light Cream
	vec3(1.0, 1.0, 1.0),                      // White
	vec3(0.114, 0.169, 0.325),                  // Deep Blue
	vec3(1.0, 0.467, 0.659),                   // Soft Pink
	vec3(0.545, 0.545, 0.545)                   // Mid-Gray
);

const mat4 DITHER_MATRIX = mat4(
	vec4( 0.0,  8.0,  2.0, 10.0),
	vec4(12.0,  4.0, 14.0,  6.0),
	vec4( 3.0, 11.0,  1.0,  9.0),
	vec4(15.0,  7.0, 13.0,  5.0)
) / 16.0;

// Helper Functions
float luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 find_closest_color(vec3 color) {
	float min_dist = 10000.0;
	vec3 closest_color = PALETTE[0];

	for (int i = 0; i < PALETTE.length(); i++) {
		float dist = distance(color, PALETTE[i]);
		if (dist < min_dist) {
			min_dist = dist;
			closest_color = PALETTE[i];
		}
	}
	return closest_color;
}

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 final_color;

	// --- NEW: Shadow Logic ---
	// Calculate the brightness of the original pixel.
	float brightness = luminance(screen_color.rgb);

	// If the pixel is darker than our threshold, force it to be the darkest color.
	if (brightness < shadow_threshold) {
		final_color = PALETTE[0]; // PALETTE[0] is black.
	} else {
		// Otherwise, apply the normal dithering and palette-finding logic.
		vec2 screen_pos = floor(FRAGCOORD.xy);
		float dither_value = DITHER_MATRIX[int(screen_pos.x) % 4][int(screen_pos.y) % 4];
		vec3 dithered_color = screen_color.rgb + (dither_value - 0.5) / 32.0;
		final_color = find_closest_color(dithered_color);
	}
	
	COLOR = vec4(final_color, screen_color.a);
}