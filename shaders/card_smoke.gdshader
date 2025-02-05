shader_type canvas_item;

uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform bool show = true;
uniform vec4 card_color = vec4(1.0, 1.0, 1.0, 1.0);

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + 
           (c - a) * u.y * (1.0 - u.x) + 
           (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;

    // Calculate the reveal mask based on noise and progress
    float noise_value = noise(uv * 10.0);
    float mask = step(noise_value, uv.y + reveal_progress * (1.0 - uv.y));

    // Reverse the mask if hiding
    if (!show) {
        mask = 1.0 - mask;
    }

    // Apply mask to the texture
    vec4 texColor = texture(TEXTURE, uv) * card_color;
    texColor.a *= mask;
    
    COLOR = texColor;
}