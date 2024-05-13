shader_type spatial;

render_mode unshaded, depth_draw_never;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_linear_mipmap;

uniform vec4 outline_color : source_color = vec4(0.f, 0.f, 0.f, 1.f);
uniform float outline_size : hint_range(0.f, 20.f) = 1.f;
uniform float depth_sensitivity : hint_range(0.01f, 2.f) = .2f;
uniform float normal_sensitivity : hint_range(0.01f, 1.f) = .1f;
uniform float color_sensitivity : hint_range(0.01f, 100.f) = .5f;

void vertex() {
	POSITION = vec4(VERTEX, 1.f);
}

float linearDepth(vec2 uv, mat4 invProjection) {
	float depth = texture(depth_texture, uv).r;
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	vec4 view = invProjection * vec4(ndc, 1.0);
  	view.xyz /= view.w;
  	return log(-view.z);
}

float logDepth(vec2 uv, mat4 invProjection) {
	return log(linearDepth(uv, invProjection));
}

float edge(vec2 uv, vec2 viewportSize, mat4 invProjection, float scale) {
	vec2 pixelSize = scale / viewportSize;
	vec2 topLeft = uv - pixelSize;
	vec2 midLeft = uv - vec2(pixelSize.x, 0.f);
	vec2 bottomLeft = uv + vec2(-pixelSize.x, pixelSize.y);
	vec2 topCenter = uv - vec2(0.f, pixelSize.y);
	vec2 center = uv;
	vec2 bottomCenter = uv + vec2(0.f, pixelSize.y);
	vec2 topRight = uv + vec2(pixelSize.x, -pixelSize.y);
	vec2 midRight = uv + vec2(pixelSize.x, 0.f);
	vec2 bottomRight = uv + pixelSize;

	float roughness = texture(normal_roughness_texture, uv).w;

	float depthResult = logDepth(topLeft, invProjection) * -.5f
		+ logDepth(midLeft, invProjection) * -1.5f
		+ logDepth(bottomLeft, invProjection) * -.5f
		+ logDepth(topCenter, invProjection) * -1.5f
		+ logDepth(center, invProjection) * 8.f
		+ logDepth(bottomCenter, invProjection) * -1.5f
		+ logDepth(topRight, invProjection) * -.5f
		+ logDepth(midRight, invProjection) * -1.5f
		+ logDepth(bottomRight, invProjection) * -.5f;

	float depthEdge = step(depth_sensitivity * depth_sensitivity, abs(depthResult));

	vec3 normalResult = texture(normal_roughness_texture, topLeft).xyz * -1.f
		+ texture(normal_roughness_texture, midLeft).xyz * -1.f
		+ texture(normal_roughness_texture, bottomLeft).xyz * -1.f
		+ texture(normal_roughness_texture, topCenter).xyz * -1.f
		+ texture(normal_roughness_texture, center).xyz * 8.f
		+ texture(normal_roughness_texture, bottomCenter).xyz * -1.f
		+ texture(normal_roughness_texture, topRight).xyz * -1.f
		+ texture(normal_roughness_texture, midRight).xyz * -1.f
		+ texture(normal_roughness_texture, bottomRight).xyz * -1.f;

	float normalEdge = step(normal_sensitivity, length(normalResult * roughness) / 4.5f);

	vec3 colorResult = texture(screen_texture, topLeft).rgb * -1.f
		+ texture(screen_texture, midLeft).rgb * -1.f
		+ texture(screen_texture, bottomLeft).rgb * -1.f
		+ texture(screen_texture, topCenter).rgb * -1.f
		+ texture(screen_texture, center).rgb * 8.f
		+ texture(screen_texture, bottomCenter).rgb * -1.f
		+ texture(screen_texture, topRight).rgb * -1.f
		+ texture(screen_texture, midRight).rgb * -1.f
		+ texture(screen_texture, bottomRight).rgb * -1.f;

	float colorEdge = step(color_sensitivity, length(colorResult) / 4.5f);

	return max(max(depthEdge, normalEdge), colorEdge);
}

void fragment() {
	float edge_strength = edge(SCREEN_UV, VIEWPORT_SIZE, INV_PROJECTION_MATRIX, outline_size);
	vec3 base_color = texture(screen_texture, SCREEN_UV).rgb;
	vec3 edge_color = mix(base_color, outline_color.rgb, outline_color.a);
	vec3 result = mix(base_color, edge_color, edge_strength);

	ALBEDO = result;
}
