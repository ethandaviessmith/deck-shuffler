shader_type canvas_item;

// Uniforms to handle the active frame on the spritesheet
uniform vec2 sprite_frame_size; // Size: (number_of_columns, number_of_rows)
uniform int current_frame;      // Current frame being displayed

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
    vec3 inverted_color = vec3(1.0) - tex_color.rgb;
    COLOR = vec4(inverted_color, tex_color.a);

	//COLOR = vec4(0.3, 0.5, 1.0, 1.0);
    // Calculate number of columns and rows in the spritesheet
    //float cols = sprite_frame_size.x;
    //float rows = sprite_frame_size.y;
//
    //// Calculate current row and column based on current_frame
    //int col = current_frame % int(cols);
    //int row = current_frame / int(cols);
//
    //// Adjust UVs to focus on the current frame region
    //vec2 frame_uv;
    //frame_uv.x = (UV.x / cols) + float(col) / cols;
    //frame_uv.y = (UV.y / rows) + float(row) / rows;
//
    //// Fetch the base color from the texture
    //vec4 base_color = texture(TEXTURE, frame_uv);
    //vec4 ghostly_color = mix(base_color, vec4(0.3, 0.5, 1.0, base_color.a), 0.5);
//
    //COLOR = vec4(ghostly_color.rgb, base_color.a);
}
//shader_type canvas_item;
//
//uniform float time;  // Pass the global time to add animation
//uniform float sparkle_frequency : hint_range(0.1, 2.0) = 0.5;
//uniform float shimmer_speed : hint_range(0.1, 3.0) = 1.0;
//uniform float shimmer_scale : hint_range(0.5, 2.0) = 1.0;
//
//void fragment() {
    //// Base color of ghostly blue
    //vec4 base_color = vec4(0.3, 0.5, 1.0, 0.6);
//
    //// Calculate shimmer effect
    //float shimmer = sin(UV.y * 10.0 * shimmer_scale + time * shimmer_speed) * 0.05;
//
    //// Calculate sparkle effect
    //float sparkle = step(0.99, fract(sin(dot(UV.xy, vec2(12.9898, 78.233))) * 43758.5453));
    //sparkle *= step(0.0, sin(time * sparkle_frequency));
//
    //// Compose final color
    //vec3 final_color = base_color.rgb + vec3(shimmer) + vec3(sparkle);
    //COLOR = vec4(final_color.rgb, base_color.a);
//}