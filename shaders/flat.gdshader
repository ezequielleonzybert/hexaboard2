shader_type spatial;

const vec3 color_highlight = vec3(.9,1.0,.6);

uniform int tile_hovered;
varying flat int instance_id;
varying vec3 color_base;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
    instance_id = INSTANCE_ID;
	color_base = COLOR.rgb;
}

void fragment() {
	if (int(instance_id) == tile_hovered) {
        ALBEDO = color_highlight;
    } else {
		float id = float(instance_id);
		float variation = random(vec2(id, 0.0)) * 0.1 + .6;
        ALBEDO = color_base;
		
		if(distance(COLOR.rgb, vec3(.4,.7,.3)) < 0.1 ){
			ALBEDO *= variation;
			ROUGHNESS = 1.0;
		}
		else{
			ROUGHNESS = 0.5;
			SPECULAR = 0.7;
		}
    }	
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}