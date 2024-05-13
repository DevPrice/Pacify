shader_type spatial;

render_mode diffuse_toon, specular_toon;

uniform vec2 uv_scale = vec2(1.f, 1.f);
uniform vec3 tint : source_color = vec3(1.f, 1.f, 1.f);
uniform sampler2D base_color : source_color, hint_default_white;
uniform float specular_size = 0.f;

global uniform sampler3D noise_texture : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float noise_scale = .25f;
uniform float wobble_speed = 4.f;
uniform float wobble_scale = .02f;

uniform float scale_min_distance = 10.f;
uniform float scale_max_distance = 80.f;
uniform float scale_max = 4.f;

uniform float hatch_intensity = 1.f;
uniform vec2 hatch_spacing = vec2(6.f);
uniform float shadow_threshold = .5f;

uniform float roughness = 1.f;

float mapToRange(float x, float inMin, float inMax, float outMin, float outMax) {
	float y = outMin + (outMax - outMin) * (x - inMin) / (inMax - inMin);
	return max(outMin, min(y, outMax));
}

void vertex() {
	vec3 noise = vec3(
		texture(noise_texture, VERTEX * .73f * noise_scale + floor(TIME * wobble_speed) * .73f).x,
		texture(noise_texture, VERTEX * .8989f * noise_scale + floor(TIME * wobble_speed) * .8989f).y,
		texture(noise_texture, VERTEX * 1.117f * noise_scale + floor(TIME * wobble_speed) * 1.117f).z
	) - vec3(.5f);
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist = length(CAMERA_POSITION_WORLD - world_position);
	float distance_scale = mapToRange(dist, scale_min_distance, scale_max_distance, 1.f, scale_max);

	VERTEX += noise.xyz * wobble_scale * distance_scale;
}

void fragment() {
	ALBEDO = tint * texture(base_color, UV * uv_scale).rgb * COLOR.rgb;
	ROUGHNESS = roughness;
}

float saturate(float x) {
	return clamp(x, 0.f, 1.f);
}

vec3 reflection(vec3 normal, vec3 light) {
	return normalize(2.f * dot(normal, light) * normal - light);
}

float specularIntensity(vec3 normal, vec3 light, vec3 view) {
	return step(1.f - specular_size, pow(saturate(dot(reflection(normal, light), view)), 4.f)) * saturate(1.f - specular_size);
}

float hatch(vec2 uv, vec2 thickness, vec2 spacing, float attenuation) {
	float horizontal = 1.f - step(thickness.y, mod(uv.y, thickness.y * (2.f + spacing.y)));
	float vertical = 1.f - step(thickness.x, mod(uv.x, thickness.x * (2.f + spacing.x)));
	return horizontal;
}

void light() {
	vec2 screen_uv = FRAGCOORD.xy / VIEWPORT_SIZE;

	vec3 lit_color = normalize(LIGHT_COLOR);

	float attenuation = step(shadow_threshold, ATTENUATION);
	vec3 shadow_pattern = mix(lit_color, vec3(-1.f), hatch(screen_uv, 1.f / VIEWPORT_SIZE, hatch_spacing, attenuation));

	vec3 unlit_color = mix(vec3(0.f), shadow_pattern, hatch_intensity);

	vec3 result = mix(unlit_color, lit_color, attenuation);
	float is_already_lit = step(1e-4f, length(DIFFUSE_LIGHT));
	DIFFUSE_LIGHT = mix(result, max(DIFFUSE_LIGHT, result), is_already_lit);

	float specular = SPECULAR_AMOUNT * specularIntensity(NORMAL, LIGHT, VIEW) * attenuation;
	SPECULAR_LIGHT += LIGHT_COLOR * specular;
}
