shader_type canvas_item;

uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 object_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;

    // Calculate adjusted progress for showing from the ground up
    float adjusted_progress = uv.y + reveal_progress;

    // Create a mask for the reveal effect
    float mask = step(0.0, adjusted_progress - 1.0);

    // Apply the mask to the object color
    vec4 texColor = object_color;
    texColor.a *= mask;
    texColor.rgb *= texColor.a;

    COLOR = texColor;
}