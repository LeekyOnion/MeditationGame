shader_type spatial;
uniform sampler2D base_texture;
uniform sampler2D draw_mask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 base_color = texture(base_texture, UV);
	float mask_value = texture(draw_mask, UV).r;
	ALBEDO = base_color.rgb * (1.0 - mask_value * 0.5);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
