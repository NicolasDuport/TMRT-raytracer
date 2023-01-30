#version 460
layout (local_size_x = 128, local_size_y = 1, local_size_z = 1) in;

#define MAX_BOUNCE 5
#define INTERSECT_EPSILON 1e-6
#define INTERSECT_MAX_DIST 1e6

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
    vec3 vertex[4];
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

uniform uint size; //number of facet
uniform vec3 origin; //TMRT source

bool planeIntersect(in vec3 ro, in vec3 rd, in vec3 planeNormal, in vec3 planePoint, out float hit) {
    float d = dot(planeNormal, planePoint);
    float t = (d - dot(planeNormal, ro)) / dot(planeNormal, rd);
    if (t < 0.0) {
        return false;
    }
    hit = t;
    return true;
}

bool IntersectTriangle(Ray ray, vec3 p0, vec3 p1, vec3 p2, out float hit)
{
    const vec3 e0 = p1 - p0;
    const vec3 e1 = p0 - p2;
    vec3 triangleNormal = cross( e1, e0 );

    const vec3 e2 = ( 1.0 / dot( triangleNormal, ray.rd ) ) * ( p0 - ray.rs );
    const vec3 i  = cross( ray.rd, e2 );
    vec3 barycentricCoord;
    barycentricCoord.y = dot( i, e1 );
    barycentricCoord.z = dot( i, e0 );
    barycentricCoord.x = 1.0 - (barycentricCoord.z + barycentricCoord.y);
    hit   = dot( triangleNormal, e2 );

    return  (hit < INTERSECT_MAX_DIST) && (hit > INTERSECT_EPSILON) && all(greaterThanEqual(barycentricCoord, vec3(0.0)));
}

bool raytrace(inout Ray r){

    bool hitSomething = false;
    bool hitFacet = false;
    float closestHit = 0;
    float hit;
    uint id;

    for(uint i = 0; i < size; i++){   //Loop for identify the facet intersected by the ray
        Facet f = facets[i];
        hitFacet = false;
        //Intersection test, result : Facet id
        //Find the closest point of the geometry on the ray path
        
        vec3 a = f.vertex[0];
        vec3 b = f.vertex[1];
        vec3 c = f.vertex[2];
        vec3 d = f.vertex[3];
        
        if(d.x != -1){ //Quad
            hitFacet = IntersectTriangle( r, a, b, c , hit); //Test first tiangle
            if(!hitFacet) hitFacet = IntersectTriangle( r, a, c, d , hit); //Test second triangle
        }else{ //Triangle
            hitFacet = IntersectTriangle( r, a, b, c , hit);
        }
        
        //if(!hitSomethingLoop) //Test floor intersection
            //hitSomethingLoop = planeIntersect(r.rs, r.rd, vec3(0,0,1), vec3(0), hit);

        if(hitFacet){
            if(!hitSomething){ //We did not hit a facet before
                hitSomething = true;
                closestHit = hit;
                id = f.id;
            }else if(closestHit > hit){
                closestHit = hit;
                id = f.id;
                

            }
        }
    }

    
    if(hitSomething){
        if(r.bounce == 0){
            r.firstHitID = id;
            r.lastHitID = id;
        }else r.lastHitID = id;

        if(facets[r.lastHitID].specular == 0) r.hitDiffuse = true;
        r.bounce++;
        r.re = r.rs + r.rd * (closestHit - 0.01);

        return true;
    }else{
        r.re = r.rs + r.rd * 0.1;
        r.hitSky = true;
        return false;
    }
}


void main() {
    uint index = gl_GlobalInvocationID.x;
    Ray r = rays[index];
    if(r.bounce > 0 && !r.hitSky && !r.hitDiffuse){
        r.rs = r.re; //Intersection points
        r.rd = reflect(r.rd, facets[r.lastHitID].normal);
        raytrace(r);
    }else if(r.bounce == 0) raytrace(r);
     
    
    rays[index] = r;
}