shader_type canvas_item;

uniform vec3 tint = vec3(1.f);

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	COLOR.rgb = texel.rgb * tint;
	COLOR.a = texel.a;
}
