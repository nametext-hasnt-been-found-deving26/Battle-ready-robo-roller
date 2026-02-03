shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float lod : hint_range(0.0, 5) = 0.0;

// A small multiplier for subtle purple tint
const vec3 TINT_COLOR = vec3(185.0 / 255.0, 0.0, 1.0);
uniform float tint_strength : hint_range(0.0, 2.0) = 0.2;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);

    // Apply a slight tint by mixing original color with tinted version
    color.rgb = mix(color.rgb, color.rgb * TINT_COLOR, tint_strength);

    COLOR = color;
}
