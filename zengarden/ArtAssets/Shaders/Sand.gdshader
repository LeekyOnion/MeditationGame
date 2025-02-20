shader_type spatial;
uniform sampler2D base_texture;
uniform sampler2D dark_texture;
uniform sampler2D draw_mask;
uniform float uv_scale = 1.0;
uniform float base_height = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	float mask = COLOR.r;
	mask *= texture(draw_mask, UV).r;
	VERTEX.y += mask * base_height;
}

void fragment() {
	/* vec4 base_color = texture(base_texture, UV);
	float mask_value = texture(draw_mask, UV).r;
	ALBEDO = base_color.rgb * (1.0 - mask_value * 0.5); */
	
	vec2 uv = UV * uv_scale;
	vec3 base_a = texture(base_texture, uv).rgb;
	vec3 dark_a = texture(dark_texture, uv).rgb;
	vec3 mask_a = texture(draw_mask, uv).rgb;
	
	float mask = COLOR.r;
	mask *= texture(draw_mask, UV).r;
	
	ALBEDO = mix(base_a, dark_a, mask_a).rgb;
	
	
	//ALBEDO = mix(base_a, dark_a, mask);
	//ALBEDO = texture(draw_mask, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
