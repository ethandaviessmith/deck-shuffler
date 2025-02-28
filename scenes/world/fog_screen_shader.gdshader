shader_type canvas_item;

uniform vec2 wave_frequency = vec2(0.1, 0.1); // Larger scale for broader formations
uniform float wave_speed = 1.0;
uniform float fog_density = 0.3; // Adjust for denser fog
uniform vec4 fog_color = vec4(0.8, 0.8, 0.8, 1.0); // Light grey fog color for visibility
uniform float transition_y = 0.5; // Control height at which transition occurs (0.0 - 1.0)

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3) - 1) / 2
    const float K2 = 0.211324865; // (3 - sqrt(3)) / 6
    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
    return dot(n, vec3(70.0));
}

float fbm(vec2 p) {
    float total = 0.0;
    float amplitude = 1.0;
    for (int i = 0; i < 4; i++) {
        total += noise(p) * amplitude;
        p *= 2.0;
        amplitude *= 0.5;
    }
    return total;
}

void fragment() {
    vec2 uv = FRAGCOORD.xy / vec2(800.0, 600.0); // Adjust this for your exact canvas size
    uv += wave_speed * vec2(sin(TIME * 0.2), cos(TIME * 0.2));
    float n = fbm(uv * wave_frequency + TIME * 0.05);
    n += 0.5 * fbm(uv * wave_frequency * 2.0);

    // Adjust fog density based on the vertical position for gradient effect
    float vertical_blend = smoothstep(0.0, transition_y, uv.y); // 0.0 to transition_y is dense
    float blended_density = mix(fog_density, fog_density * 0.75, vertical_blend);

    float fog_factor = smoothstep(blended_density - 0.1, blended_density + 0.1, n);
    COLOR = mix(vec4(0.2, 0.2, 0.2, 1.0), fog_color, fog_factor);
}