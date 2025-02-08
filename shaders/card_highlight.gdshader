shader_type canvas_item;

uniform bool smudge_on = false;
uniform float smudge_intensity = 0.0;

uniform bool ghost_effect_on = true;
uniform float ghost_intensity = 0.05;

uniform float time;

void fragment() {
    vec2 uv = UV;

    // Smudge Effect
    if (smudge_on) {
        uv.x += cos(uv.y * 20.0 + time * 5.0) * smudge_intensity;
        uv.y += sin(uv.x * 20.0 + time * 5.0) * smudge_intensity;
    } 
    // Ghost Effect (Wavy Movement)
    if (ghost_effect_on) {
        uv.y += sin(uv.x * 10.0 + time) * ghost_intensity;
        uv.x += cos(uv.y * 10.0 + time) * ghost_intensity;
    }
	

    vec4 tex_color = texture(TEXTURE, uv);
    COLOR = tex_color;
}