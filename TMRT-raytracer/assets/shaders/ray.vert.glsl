#version 460 core

#define MAX_BOUNCE 5
struct Ray {
    vec3 o; //Origin
    vec3 d; //Direction
    vec3 e; //End
    uint hitID;
    uint bounce;
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
	vec3 start = rays[gl_InstanceID].o;
	vec3 end = rays[gl_InstanceID].e;

	normal = rays[gl_InstanceID].d;
	if(length(_position) == 0.0){
		position = start;
	}else{
		position = end;
	}
	color = rays[gl_InstanceID].hitID != uint(-1) ? vec3(0,1,0) : vec3(1,0,0);
	gl_Position = view * vec4(position, 1.0f);
} 
