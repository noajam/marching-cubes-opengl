#version 400 core

layout (points) in;
layout (triangle_strip, max_vertices=16) out;

//Volume data field texture
uniform sampler3D Scalar3D;
//2D mountain texture
uniform sampler2D Tex;
//Edge table texture
uniform isampler2D EdgeTable;
//Triangles table texture
uniform isampler2D TriTable;

// Lighting uniforms
uniform float fov;
uniform vec4 Global;
uniform vec4 Ambient;
uniform vec4 Diffuse;
uniform vec4 Specular;
uniform vec4 Position;

// Surface to render
uniform int surface;

//Global iso level
uniform float isovalue;
uniform float cubeStep;
uniform float gridSpace;

uniform mat4 ModelViewMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;
uniform mat3 NormalMatrix;

out vec2 texCoord;
out vec4 color;

uniform vec3 vertexOffsets[8];

//Get vertex i position within current marching cube
vec3 cubePos(int i){
	return gl_in[0].gl_Position.xyz + vertexOffsets[i];
}

vec4 sampleFunction( vec3 p )
{
    return vec4(
        16.0*p.y*p.z +
        4.0*2.0*p.x,
        16.0*p.x*p.z +
        4.0*2.0*p.y,
        16.0*p.x*p.y +
        4.0*2.0*p.z,
        16.0*p.x*p.y*p.z +
        4.0*p.x*p.x +
        4.0*p.y*p.y +
        4.0*p.z*p.z - 1.0
        );
}

// Sphere, where inside ranges from 0 to 1, and outside is 1
float sphereFunction(vec3 p)
{
	return smoothstep(0.0, 1.0, length(p));
}

//Get vertex i value within current marching cube
float cubeVal(int i){
	if (surface == 0)
		return sampleFunction(cubePos(i)).a;
	else if (surface == 1)
		return sphereFunction(cubePos(i));
	else
	{
		// Get cube position
		vec3 pos = cubePos(i);

		// Setup coordinate lookup based on position in space
		vec3 coord = smoothstep(-gridSpace/2,gridSpace/2,pos);
		float density = coord.y - 0.5;
		density += texture(Scalar3D, coord).r;
		//density += texture(Scalar3D, coord*0.5).r*2.00;
		return density;
	}
}

//Get edge table value
int edgeTableValue(int i){
	return texelFetch(EdgeTable, ivec2(i, 0), 0).r;
}

//Get triangle table value
int triTableValue(int i, int j){
	return texelFetch(TriTable, ivec2(j, i), 0).r;
}

//Compute interpolated vertex along an edge
vec3 vertexInterp(float isovalue, vec3 v0, float l0, vec3 v1, float l1){
	return mix(v0, v1, (isovalue-l0)/(l1-l0));
}

vec3 faceNormal(vec3 A, vec3 B, vec3 C)
{
	vec3 AB = A-B;
	vec3 AC = A-C;
	return -cross(AB, AC);
}

vec4 phong(vec3 Normal, vec4 Color, vec4 Vertex)
{
   //  P is the vertex coordinate on body
   vec3 P = vec3(ModelViewMatrix * Vertex);
   //  N is the object normal at P
   vec3 N = normalize(NormalMatrix * Normal);
   //  L is the light vector
   vec3 L = normalize(vec3(ViewMatrix*Position) - P);

   //  Emission and ambient color
   vec4 color = (Global+Ambient)*Color;

   //  Diffuse light intensity is cosine of light and normal vectors
   float Id = dot(L,N);
   if (Id>0.0)
   {
      //  Add diffuse - material color from Color
      color += Id*Diffuse*Color;
      //  R is the reflected light vector R = 2(L.N)N - L
      vec3 R = reflect(-L, N);
      //  V is the view vector (eye at the origin)
      vec3 V = (fov>0.0) ? normalize(-P) : vec3(0,0,1);
      //  Specular is cosine of reflected and view vectors
      //  Assert material specular color is white
      float Is = dot(R,V);
      if (Is>0.0) color += pow(Is,8.0)*Specular;
   }

   //  Return sum of color components
   return color;
}

vec4 yToRgb(float y)
{    
    float r, g, b;
    
    b = clamp(1.0-y*2.0, 0.0, 1.0);
    g = 1.0-abs(y*2.0-1.0);
    r = clamp((y-0.5)*2.0, 0.0, 1.0);
    
    return vec4(r, g, b, 1.0);
}

//Geometry Shader entry point
void main(void) {
    mat4 ModelViewProjectionMatrix = ProjectionMatrix * ModelViewMatrix;
	
	int cubeindex=0;

    // Determine the index into the edge table which
    // tells us which vertices are inside of the surface
	float cubeVal0 = cubeVal(0);
	float cubeVal1 = cubeVal(1);
	float cubeVal2 = cubeVal(2);
	float cubeVal3 = cubeVal(3);
	float cubeVal4 = cubeVal(4);
	float cubeVal5 = cubeVal(5);
	float cubeVal6 = cubeVal(6);
	float cubeVal7 = cubeVal(7);

	cubeindex = int(cubeVal0 < isovalue);
	cubeindex += int(cubeVal1 < isovalue)*2;
	cubeindex += int(cubeVal2 < isovalue)*4;
	cubeindex += int(cubeVal3 < isovalue)*8;
	cubeindex += int(cubeVal4 < isovalue)*16;
	cubeindex += int(cubeVal5 < isovalue)*32;
	cubeindex += int(cubeVal6 < isovalue)*64;
	cubeindex += int(cubeVal7 < isovalue)*128;

	// Cube is entirely in/out of the surface
	if (edgeTableValue(cubeindex) == 0)
		return;

	vec3 cubePos0 = cubePos(0);
    vec3 cubePos1 = cubePos(1);
    vec3 cubePos2 = cubePos(2);
    vec3 cubePos3 = cubePos(3);
    vec3 cubePos4 = cubePos(4);
    vec3 cubePos5 = cubePos(5);
    vec3 cubePos6 = cubePos(6);
    vec3 cubePos7 = cubePos(7);
    

	// Find vertices where surface intersects cube
    vec3 vertlist[12];

	vertlist[0] = vertexInterp(isovalue, cubePos0, cubeVal0, cubePos1, cubeVal1); 
	vertlist[1] = vertexInterp(isovalue, cubePos1, cubeVal1, cubePos2, cubeVal2); 
	vertlist[2] = vertexInterp(isovalue, cubePos2, cubeVal2, cubePos3, cubeVal3); 
	vertlist[3] = vertexInterp(isovalue, cubePos3, cubeVal3, cubePos0, cubeVal0); 
	vertlist[4] = vertexInterp(isovalue, cubePos4, cubeVal4, cubePos5, cubeVal5); 
	vertlist[5] = vertexInterp(isovalue, cubePos5, cubeVal5, cubePos6, cubeVal6); 
	vertlist[6] = vertexInterp(isovalue, cubePos6, cubeVal6, cubePos7, cubeVal7); 
	vertlist[7] = vertexInterp(isovalue, cubePos7, cubeVal7, cubePos4, cubeVal4); 
	vertlist[8] = vertexInterp(isovalue, cubePos0, cubeVal0, cubePos4, cubeVal4); 
	vertlist[9] = vertexInterp(isovalue, cubePos1, cubeVal1, cubePos5, cubeVal5); 
	vertlist[10] = vertexInterp(isovalue, cubePos2, cubeVal2, cubePos6, cubeVal6); 
	vertlist[11] = vertexInterp(isovalue, cubePos3, cubeVal3, cubePos7, cubeVal7);

	int i=0;		
	vec3 A;
	vec3 B;
	vec3 C;
	vec3 normal;
	vec4 rgb;
	while (triTableValue(cubeindex, i) != -1)
	{
		//Generate first vertex of triangle//
		//Fill position varying attribute for fragment shader

		// Calculate 3 vertices, then use those to make a normal
		// Test that, then try orienting the normal a different way if it doesn't work
		
		A = vec3(vertlist[triTableValue(cubeindex, i)]);
		B = vec3(vertlist[triTableValue(cubeindex, i+1)]);
		C = vec3(vertlist[triTableValue(cubeindex, i+2)]);
		normal = faceNormal(A, B, C);
		rgb = vec4(1,1,1,1);

		//Fill gl_Position attribute for vertex raster space position
		texCoord = smoothstep(-gridSpace/2,gridSpace/2,A.xz);
		color = phong(normal, rgb, vec4(A, 1));
		gl_Position = ModelViewProjectionMatrix * vec4(A, 1);
		EmitVertex();
		
		//Generate second vertex of triangle//
		//Fill gl_Position attribute for vertex raster space position
		texCoord = smoothstep(-gridSpace/2,gridSpace/2,B.xz);
		color = phong(normal, rgb, vec4(B, 1));
		gl_Position = ModelViewProjectionMatrix * vec4(B, 1);
		EmitVertex();

		//Generate last vertex of triangle
		//Fill gl_Position attribute for vertex raster space position
		texCoord = smoothstep(-gridSpace/2,gridSpace/2,C.xz);
		color = phong(normal, rgb, vec4(C, 1));
		gl_Position = ModelViewProjectionMatrix * vec4(C, 1);
		EmitVertex();
		
		//End triangle strip at first triangle
		EndPrimitive();
		
		i += 3;
	}
}
