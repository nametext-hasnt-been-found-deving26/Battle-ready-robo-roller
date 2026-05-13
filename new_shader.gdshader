shader_type canvas_item;

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
    vec4 tex = texture(TEXTURE, UV);
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;

    // --- Detect top edge ---
    float above_alpha = texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;
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

    bool is_protected = (diff1 < tolerance) || (diff2 < tolerance) || (diff3 < tolerance) || (diff4 < tolerance) || (diff5 < tolerance) || (diff6 < tolerance) || (diff7 < tolerance) || (diff8 < tolerance) || (diff9 < tolerance);;

    vec3 final_color;

    if (is_protected) {
        // Apply ONLY replacement, no shading
        if (diff1 < tolerance) {
            final_color = replacement_color.rgb;
        } else if (diff2 < tolerance) {
            final_color = replacement_color2.rgb;
        } else if (diff3 < tolerance){
            final_color = replacement_color3.rgb;
        } else if (diff4 < tolerance){
            final_color = replacement_color4.rgb;
        } else if (diff5 < tolerance){
            final_color = replacement_color5.rgb;
        } else if (diff6 < tolerance){
            final_color = replacement_color6.rgb;
        } else if (diff7 < tolerance){
            final_color = replacement_color7.rgb;
        } else if (diff8 < tolerance){
            final_color = replacement_color8.rgb;
        } else if (diff9 < tolerance){
            final_color = replacement_color9.rgb;
        }
    } else {
        // Apply shading normally
        final_color = tex.rgb;
		if (in_dark_place == true){
			if (is_top) {
				final_color += brighten;
				} else {
					final_color -= darken;
					}
		}     
    }

   
	
	 COLOR = vec4(final_color, tex.a);

}
