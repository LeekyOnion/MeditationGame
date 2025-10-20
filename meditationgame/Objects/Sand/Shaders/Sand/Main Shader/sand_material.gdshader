shader_type spatial;
render_mode specular_schlick_ggx, diffuse_burley;

// Color of the Shader
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

// Maps 1 and 2 for Parallaxing Effect
uniform sampler2D normal_map;
uniform sampler2D depth_map;
uniform sampler2D normal_map2;
uniform sampler2D depth_map2;

uniform sampler2D sand;

// Scaling for the aggressiveness of wave distortions
uniform float height_scale : hint_range(0.0, 1.0) = 0.03;

// Textures for Depth
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Out Variables Vertex
varying vec3 frag_pos; // WORLD SPACE
varying vec3 tangent_view_pos;
varying vec3 tangent_frag_pos;
varying vec3 world_position;
varying vec3 test;

// UV manipulation
uniform float uv_x_mod : hint_range(-1.0, 1.0, 0.05) = 0.0;
uniform float uv_y_mod : hint_range(-1.0, 1.0, 0.05) = 0.0;
uniform float uv2_x_mod : hint_range(-1.0, 1.0, 0.05) = 0.0;
uniform float uv2_y_mod : hint_range(-1.0, 1.0, 0.05) = 0.0;
uniform float uv_scale : hint_range(1.0, 10.0, 0.5) = 1.0;
uniform float uv2_scale : hint_range(1.0, 10.0, 0.5) = 1.0;


// The fresnel effect
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

mat3 Calculate_TBN(mat4 Model_Matrix, vec3 T, vec3 N)
{
    // Calculate Tangent, BiTangent and Normals into World Space
    vec3 Tangent   = normalize(mat3(Model_Matrix) * T);
    vec3 Normal    = normalize(mat3(Model_Matrix) * N);

    vec3 BiTangent = normalize(cross(Tangent, Normal));
    mat3 TBN = transpose(mat3(Tangent, BiTangent, Normal));

    return TBN;
}

void vertex() {

	// GET VARIABLES
	frag_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// TBN Calculation
	mat3 TBN = Calculate_TBN(MODEL_MATRIX, TANGENT, NORMAL);

	// Tangent View and Frag Positions
	tangent_view_pos = TBN * CAMERA_POSITION_WORLD;
	tangent_frag_pos = TBN * frag_pos;
	test = vec3(abs(dot(transpose(TBN)[2], transpose(TBN)[1])));
	UV  = vec2(UV.x  , UV.y) * uv_scale;
	UV2 = vec2(UV2.x , UV2.y) * uv2_scale;
}

vec2 ParallaxMapping(vec2 _uv, vec3 View_Direction)
{
	// STEEP PARALLAX MAPPING
	const float minLayers = 64.0;
	const float maxLayers = 258.0;

	//const float numLayers = 10.0;
	float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0,0.0,1.0), View_Direction)));
	float layerDepth = 1.0 / numLayers;
	float currentLayerDepth = 0.0;

	float view_z = max(View_Direction.z, 0.001); // Avoid division by zero, ensure positive
	vec2 p = View_Direction.xy / view_z * height_scale;
	vec2 DeltaTexCoords = p / numLayers;
	vec2 tempUV = _uv;
	float currentDepthMapValue = 1.0 - texture(depth_map, tempUV).r;

	while (currentLayerDepth < currentDepthMapValue)
	{
		tempUV -= DeltaTexCoords;
		currentDepthMapValue = texture(depth_map, tempUV).r;
		currentLayerDepth += layerDepth;
	}

	// PARALLAX OCCLUSION MAPPING
	vec2 prevUV = tempUV + DeltaTexCoords;

	float afterDepth  = currentDepthMapValue - currentLayerDepth;
	float beforeDepth = texture(depth_map, prevUV).r - currentLayerDepth + layerDepth;

	float weight = afterDepth / (afterDepth - beforeDepth);
	vec2 finalUV = prevUV * weight + tempUV * (1.0 - weight);

	return finalUV;
}

vec3 displace(sampler2D _normal, vec2 _uv)
{
vec3 duv = vec3(4.0 / 512.0, 4.0 / 512.0, 0);
float v1 = texture(_normal, _uv - duv.xz).y;
float v2 = texture(_normal, _uv + duv.xz).y;
float v3 = texture(_normal, _uv - duv.zy).y;
float v4 = texture(_normal, _uv + duv.zy).y;

vec3 normal = normalize(vec3(v1 - v2, v3 - v4, 1.0));

return normal;
}

void fragment()
{
	/// DEPTH MATH
	// Code to make the water function as water or light blocking - depth variables
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 -1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth+VERTEX.z));
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

	// Color for the depth
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;

	// Calculations for the Fresnel Effect
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);

	/// PARALLAX CALCULATIONS
	// VARIABLES
	vec3 ViewDirection = normalize(tangent_view_pos - tangent_frag_pos);

	// AVERAGE THE UV HEIGHTS
	vec2 AvgUV = (UV + UV2) / 2.0;

	// ADJUSTED UV CALCULATIONS
	vec2 AdjustedUV = ParallaxMapping(UV, ViewDirection);
	vec2 AdjustedUV2 = AdjustedUV - UV + UV2;

	// Displace Normals

	// OUTPUTS
	vec3 AdjustedNormal1 = texture(normal_map, AdjustedUV).rgb;
	vec3 AdjustedNormal2 = texture(normal_map2, AdjustedUV2).rgb;

	// MIX THESE OUTPUT OF ADJUSTED NORMALS
	vec3 FinalNormal = mix(AdjustedNormal1, AdjustedNormal2, 0.5);

	// FINAL OUTPUTS
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = FinalNormal - displace(sand, UV) * 0.5;
	//NORMAL_MAP = mix(FinalNormal, displace(sand, UV), 0.50);
	//NORMAL = displace(sand, UV) + FinalNormal;
	ALBEDO = clamp(surface_color, vec3(0.0), vec3(1.0));
}
