shader_type spatial;

const vec3 color_base = vec3(.4,.7,.3);
const vec3 color_highlight = vec3(.9,1.0,.6);

uniform int tile_hovered;
varying flat int instance_id;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
    instance_id = INSTANCE_ID;
}

void fragment() {
	if (int(instance_id) == tile_hovered) {
        ALBEDO = color_highlight;
    } else {
		float id = float(instance_id);
        vec3 colorin = vec3(
            random(vec2(id, 0.0)),
            random(vec2(id, 1.0)),
            random(vec2(id, 2.0))
        );
		float variation = random(vec2(id, 0.0)) * 0.1 + .6;
        ALBEDO = color_base * variation;
    }	
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}