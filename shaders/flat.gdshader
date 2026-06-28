shader_type spatial;

const vec3 color_base = vec3(.4,.7,.3);
const vec3 color_highlight = vec3(.9,1.0,.6);

uniform int tile_hovered;
varying flat int instance_id;

void vertex() {
    instance_id = INSTANCE_ID;
}

void fragment() {
	if (int(instance_id) == tile_hovered) {
        ALBEDO = color_highlight;
    } else {
        ALBEDO = color_base;
    }	
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}