shader_type canvas_item;

uniform float wipe_amount : hint_range(0.0, 1.0);

void fragment() {
    vec2 uv = UV;
    if (uv.y <  wipe_amount) {
        discard;
    }
    COLOR = texture(TEXTURE, uv) * COLOR;
}