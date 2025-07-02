shader_type spatial;

uniform sampler2D base_tex;
uniform sampler2D blend_tex_1;
uniform sampler2D blend_tex_2;
uniform sampler2D blend_tex_3;
uniform int amount_changes;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 base = texture(base_tex, UV);
	vec4 mask1 = texture(blend_tex_1, UV);
	vec4 mask2 = texture(blend_tex_2, UV);
	vec4 mask3 = texture(blend_tex_3, UV);
	
	if (amount_changes == 1)
	{
		vec4 blend1 = mix(base, mask1, mask1.a);
		ALBEDO = blend1.rgb;
	}
	else if (amount_changes == 2)
	{
		vec4 blend1 = mix(mask1, mask2, mask2.a);
		vec4 blend2 = mix(base, blend1, blend1.a);
		ALBEDO = blend2.rgb;
	}
	else if (amount_changes == 3)
	{
		vec4 blend1 = mix(mask1, mask2, mask2.a);
		vec4 blend2 = mix(blend1, mask3, mask3.a);
		vec4 blend3 = mix(base, blend2, blend2.a);
		ALBEDO = blend3.rgb;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
