#version 460 core

#define MAX_BOUNCE 5
struct Ray {
    vec3 ro; //Origin
    vec3 rd; //Direction
    vec3 rs; //Start
    vec3 re; //End
    uint firstHitID;
    uint lastHitID;
    uint bounce;
    bool hitSky;
};


layout (std430, binding = 1) buffer RayBuffer {
  Ray rays[];
};

layout (location = 0) in vec3 _position;
layout (location = 1) in vec3 _normal;
layout (location = 2) in vec3 _color;
layout (location = 3) in vec2 _texCoord;

uniform mat4 view;
uniform mat4 model;

out vec3 position;
out vec3 offset;
out vec3 normal;
out vec3 color;
out vec2 texCoord;


void main() {
	vec3 start = rays[gl_InstanceID].rs;
	vec3 end = rays[gl_InstanceID].re;

	normal = rays[gl_InstanceID].rd;
	if(length(_position) == 0.0){
		position = start;

		if( rays[gl_InstanceID].hitSky){
			color = vec3(0,0,1);
		}else{
			if(rays[gl_InstanceID].bounce == 1){
				color = vec3(0,1,0);
			}else if(rays[gl_InstanceID].bounce > 1) color = vec3(1,0,0);
			else color = vec3(1);
		}


	}else{
		position = end;
		color =  vec3(1,1,1);
	}
	
	gl_Position = view * vec4(position, 1.0f);
} 
