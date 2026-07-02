shader_type spatial;

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
        ALBEDO = mix(color_base,vec3(1.0,1.0,1.0),0.1);
    } else {
		float id = float(instance_id);
		float variation = random(vec2(id, 0.0)) * 0.1 + .6;
        ALBEDO = color_base;
		
		if(distance(COLOR.rgb, vec3(.5,.7,1.0)) < 0.1 ){ //water
			ROUGHNESS = 0.5;
			SPECULAR = 0.7;
		}
		else{
			ALBEDO *= variation;
			ROUGHNESS = 1.0;
		}
    }	
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}