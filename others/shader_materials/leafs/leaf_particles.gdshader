shader_type canvas_item;

uniform float strength = 0.3;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    tex.rgb *= strength;
    tex.a   *= strength;

    COLOR = tex;
}