shader_type canvas_item;

uniform float glow_strength = 1.2;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Base leaf (normal opacity)
    vec3 base = tex.rgb;

    // Create a glow mask from brightness or alpha
    float glow_mask = tex.a; // or use brightness: dot(tex.rgb, vec3(0.333))

    // Blue glow color
	vec3 glow_color;
	if (tex.a > 0.9) {
    glow_color = vec3(0.2, 0.6, 1.0);
}
    // Control glow strength


    // Final color: solid leaf + additive glow component
    vec3 final_color = base + glow_color * glow_mask * glow_strength;

    COLOR = vec4(final_color, tex.a);
}