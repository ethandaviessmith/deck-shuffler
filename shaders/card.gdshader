shader_type canvas_item;

uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform bool show = true;
uniform vec4 object_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;

    float adjusted_progress;
    if (show) {
        // Adjust for full coverage from bottom to top
        adjusted_progress = uv.y + reveal_progress;
    } else {
        // Adjust for full coverage from top to bottom
        adjusted_progress = 1.0 - uv.y - reveal_progress;
    }

    // Ensure the mask is applied over the full height
    float mask = step(0.0, adjusted_progress);

    // Apply the mask to the object color
    vec4 texColor = object_color;
    texColor.a *= mask;
    texColor.rgb *= texColor.a;

    COLOR = texColor;
}