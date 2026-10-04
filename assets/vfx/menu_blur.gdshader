shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 3.5;
uniform vec4 tint_color : source_color = vec4(0.02, 0.025, 0.035, 0.65);
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.8;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = vec4(0.0);
	float total = 0.0;
	float radius = blur_amount * 0.0028;

	// 7x7 Gaussian kernel sample
	for (float x = -3.0; x <= 3.0; x += 1.0) {
		for (float y = -3.0; y <= 3.0; y += 1.0) {
			float weight = exp(-(x * x + y * y) / 6.5);
			vec2 offset = vec2(x, y) * radius;
			col += texture(screen_texture, uv + offset) * weight;
			total += weight;
		}
	}
	col /= total;

	// Dark atmospheric vignette
	vec2 center_uv = uv - vec2(0.5);
	float dist = length(center_uv * vec2(1.0, 1.15));
	float vig = smoothstep(0.3, 0.85, dist) * vignette_intensity;

	vec4 final_col = mix(col, tint_color, tint_color.a);
	final_col.rgb = mix(final_col.rgb, vec3(0.005, 0.008, 0.012), clamp(vig, 0.0, 0.95));

	COLOR = final_col;
}
