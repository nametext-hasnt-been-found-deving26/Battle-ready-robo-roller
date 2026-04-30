shader_type canvas_item;
uniform sampler2D leaf_texture : source_color, filter_nearest;
varying vec2 local_pos;

uniform int particle_count = 30;
uniform float speed = 0.3;
uniform float size = 0.02;
uniform float lifetime = 3.0;
uniform float overlap_boost_mult = 1.5;

uniform vec2 rect_size;


float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

float rand2(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
    local_pos = VERTEX.xy;
}

void fragment() {
    vec4 col = vec4(0.0);
    float overlap = 0.0;

    for (int i = 0; i < particle_count; i++) {
        float fi = float(i);
        float seed = fi * 10.0;

        float x = rand(seed) * rect_size.x;

        float start_time = rand(seed + 1.0) * 10.0;
        float t = mod(TIME - start_time, lifetime);
        float life = t / lifetime;
        float speed_px = rect_size.y / lifetime;
        float y = t * speed_px;

        vec2 pos = vec2(x, y);
		
		float max_dist = size * 1.5;
		if (abs(local_pos.x - pos.x) > max_dist || abs(local_pos.y - pos.y) > max_dist) {
			    continue;
				}


        // drift
        pos.x += sin(life * 6.28 + seed) * 40.0;

        // rotation

        float angle = rand(seed + 2.0) * 6.2831 + TIME * (0.5 + rand(seed + 3.0));
        mat2 rot = mat2(
            vec2(cos(angle), sin(angle)),
            vec2(-sin(angle), cos(angle))
        );

        vec2 local = local_pos - pos;
        local /= size;
        local = rot * local;

        vec2 leaf_uv = local + 0.5;

        // clip outside
        if (leaf_uv.x < 0.0 || leaf_uv.x > 1.0 || leaf_uv.y < 0.0 || leaf_uv.y > 1.0) {
            continue;
        }

        vec4 leaf = texture(leaf_texture, leaf_uv);

        float a = leaf.a;

        overlap += a;
        col += leaf * a;
    }

    // normalize base color
    vec4 base = col / max(overlap, 1.0);

    // overlap-based boost
    float boost = smoothstep(1.0, 2.5, overlap);
    boost = pow(boost, overlap_boost_mult); // slower start, stronger peak
    vec3 final_color = base.rgb + col.rgb * boost *  overlap_boost_mult;

    COLOR = vec4(final_color, base.a);
}