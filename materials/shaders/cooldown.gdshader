shader_type canvas_item;

uniform vec3 tint = vec3(.5f);
uniform float cooldown_percent : hint_range(0.f, 1.f) = .9f;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float saturate(float x) {
	return clamp(x, 0.f, 1.f);
}

void fragment() {
	vec4 texel = texture(screen_texture, SCREEN_UV);
	float angle = atan(UV.y - .5f, UV.x - .5f) + PI * .5f;
	COLOR = mix(texel * vec4(tint, 1.f), texel, step(mod(angle, 2.f * PI), saturate(cooldown_percent) * 2.f * PI));
}
