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

float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

float billow_noise(vec2 st) {
    return abs(fbm(st) * 2.0 - 1.0);
}

void fragment() {
    vec2 uv = UV;

    // Compute fire-like noise
    float noise_value = fbm(uv * 10.0);
    // Add billowing smoke effect
    float smoke_noise = billow_noise(uv * 6.0 + reveal_progress * 2.0);

    // Linearize reveal progress for a smooth start throughout the animation
    float linear_progress = show ? reveal_progress: 1.0 - reveal_progress;

    // Adjust reveal so the bottom is visible first and last
    //float adjusted_y = uv.y * (1.0 - linear_progress) + linear_progress;
	float adjusted_y = uv.y + reveal_progress;

	// TODO I just added a -0.5 to get it close enough

    // Create mask for the reveal effect
    float mask = step(noise_value, adjusted_y + smoke_noise * 0.2 - 0.6);// + smoke_noise * 0.2);

    // Adjust visibility based on show/hide
    if (!show) {
        mask = 1.0 - mask; // Reverse to hide
    }

    // Apply the mask to the texture
    vec4 texColor = texture(TEXTURE, uv) * card_color;
    texColor.a *= mask;
    texColor.rgb *= texColor.a;

    COLOR = texColor;
}