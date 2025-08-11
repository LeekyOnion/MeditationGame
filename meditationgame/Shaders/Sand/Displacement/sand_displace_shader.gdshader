shader_type canvas_item;
 
uniform sampler2D sim_tex;
uniform sampler2D col_tex;
 
uniform float phase = -0.01;
uniform float attenuation = 1.0;
uniform float deltaUV = 3.0;
 
void fragment() {
	
    float dv = 1.0 / 512.0;
    float du = 1.0 / 512.0;
    vec3 duv = vec3(du, dv, 0) * deltaUV;
 
	// think that sim_tex is the result of sand_displace_shader from a prev frame
    vec3 c = texture(sim_tex, UV).rgb;
 
    float p = (2.0 * c.r - c.g + phase * (
        texture(sim_tex, UV - duv.zy).r +
        texture(sim_tex, UV + duv.zy).r +
        texture(sim_tex, UV - duv.xz).r +
        texture(sim_tex, UV + duv.xz).r - 4.0 * c.r)) * attenuation;
        
    vec2 col_uv = vec2(UV.x, 1.0 - UV.y);
    float col = texture(col_tex, col_uv).r; // intersection data from curr frame
    float prevCol = texture(sim_tex, UV).b; // intersection data from prev frame
    
    if (col > 0.0 && prevCol == 0.0) {
        p += col * 0.5;
    }
    
    if (prevCol > 0.0 && col == 0.0) {
        p -= prevCol * 0.5;
    }
	
    COLOR = vec4(min(1, col + c.r), c.r, col, 1);
    //COLOR = vec4(p, c.r, col, 1);
}