#version 460

layout (local_size_x = 128, local_size_y = 1, local_size_z = 1) in;

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
    bool hitDiffuse;
};


struct Facet {
    vec4 vertex[4];
    vec3 normal;
    uint id;
    uint specular;
};

layout (std430, binding = 1) buffer RayBuffer {
  Ray rays[];
};

layout (std430, binding = 2) buffer FacetBuffer {
  Facet facets[];
};

uniform vec3 origin; //TMRT source

void main() {
  uint index = gl_GlobalInvocationID.x;

  Ray r = rays[index];
  r.rd = normalize(r.ro); //Compute Ray direction
  r.ro = r.ro;
  r.rs = origin + r.ro;
  r.re = r.rs + 0.1*r.rd;
  r.firstHitID = 0;
  r.lastHitID = 0;
  r.hitSky = false;
  r.hitDiffuse = false;
  r.bounce = 0;
  rays[index] = r;
}