shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;

uniform vec4 target_color : source_color = vec4(0.09, 0.039, 0.11, 1.0); 
uniform vec4 replacement_color : source_color = vec4(0.286, 0.6, 1.0, 1.0);

uniform vec4 target_color2 : source_color = vec4(0.38, 0.055, 0.502, 1.0); 
uniform vec4 replacement_color2 : source_color = vec4(0.525, 0.714, 0.957, 1.0); 

uniform vec4 target_color3 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color3 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform vec4 target_color4 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color4 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform vec4 target_color5 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color5 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform vec4 target_color6 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color6 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform vec4 target_color7 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color7 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform vec4 target_color8 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color8 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform vec4 target_color9 : source_color = vec4(0.549, 0.133, 0.706, 1.0); 
uniform vec4 replacement_color9 : source_color = vec4(0.675, 0.796, 0.949, 1.0);

uniform float tolerance : hint_range(0.0, 1.0) = 0.1;

uniform float brighten = 0.35;
uniform float darken = 0.5;

uniform bool in_dark_place = false;
void fragment() {
    vec4 tex = texture(sprite_texture, UV);
    vec2 pixel_size = 1.0 / vec2(textureSize(sprite_texture, 0));

    // --- Detect top edge ---
    float above_alpha = texture(sprite_texture, UV + vec2(0.0, -pixel_size.y)).a;
    bool is_top = tex.a > 0.1 && above_alpha < 0.1;

    // --- Detect protected colors ---
    float diff1 = distance(tex.rgb, target_color.rgb);
    float diff2 = distance(tex.rgb, target_color2.rgb);
    float diff3 = distance(tex.rgb, target_color3.rgb);
	float diff4 = distance(tex.rgb, target_color4.rgb);
	float diff5 = distance(tex.rgb, target_color5.rgb);
	float diff6 = distance(tex.rgb, target_color6.rgb);
	float diff7 = distance(tex.rgb, target_color7.rgb);
	float diff8 = distance(tex.rgb, target_color8.rgb);
	float diff9 = distance(tex.rgb, target_color9.rgb);


vec3 final_color = tex.rgb; // initialize safely

bool is_protected = (
    diff1 < tolerance 
    
);

if (is_protected) {
    if (diff1 < tolerance) {
        //final_color = replacement_color.rgb;
    } else if (diff2 < tolerance) {
        //final_color = replacement_color2.rgb;
    }
    // etc...
} else {
    if (in_dark_place) {
        if (is_top) {
            final_color += brighten;
        } else {
            final_color -= darken;
        }
    }
}

// 🔥 prevent black crush
	final_color = clamp(final_color, 0.0, 1.0);

	ALBEDO = final_color;
	ALPHA = tex.a;
}