#version 330 core

layout (points) in;
layout (triangle_strip, max_vertices=16) out;

//Volume data field texture
uniform sampler3D Scalar3D;
//Edge table texture
uniform isampler2D EdgeTable;
//Triangles table texture
uniform isampler2D TriTable;

// Surface to render
uniform int surface;

//Global iso level
uniform float isovalue;
uniform float cubeStep;
uniform float gridSpace;

uniform mat4 ModelViewMatrix;
uniform mat4 ProjectionMatrix;

out vec4 FrontColor;
out vec4 position;

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
		vec3 coord = smoothstep(-gridSpace/2,gridSpace/2,cubePos(i));
		return texture(Scalar3D, coord).g;
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

//Geometry Shader entry point
void main(void) {
    mat4 ModelViewProjectionMatrix = ProjectionMatrix * ModelViewMatrix;
	
	int cubeindex=0;

    //Determine the index into the edge table which
    //tells us which vertices are inside of the surface
	if (cubeVal(0) < isovalue) cubeindex = cubeindex | 1;
	if (cubeVal(1) < isovalue) cubeindex = cubeindex | 2;
	if (cubeVal(2) < isovalue) cubeindex = cubeindex | 4;
	if (cubeVal(3) < isovalue) cubeindex = cubeindex | 8;
	if (cubeVal(4) < isovalue) cubeindex = cubeindex | 16;
	if (cubeVal(5) < isovalue) cubeindex = cubeindex | 32;
	if (cubeVal(6) < isovalue) cubeindex = cubeindex | 64;
	if (cubeVal(7) < isovalue) cubeindex = cubeindex | 128;
	

	//Cube is entirely in/out of the surface
	if (edgeTableValue(cubeindex) == 0)
		return;
    
    vec3 vertlist[12];
    
	//Find the vertices along the edges where the surface intersects the cube
	if ((edgeTableValue(cubeindex) & 1) !=0 )
		vertlist[0] = vertexInterp(isovalue, cubePos(0), cubeVal(0), cubePos(1), cubeVal(1));
	if ((edgeTableValue(cubeindex) & 2) !=0 )
		vertlist[1] = vertexInterp(isovalue, cubePos(1), cubeVal(1), cubePos(2), cubeVal(2));
	if ((edgeTableValue(cubeindex) & 4) !=0)
		vertlist[2] = vertexInterp(isovalue, cubePos(2), cubeVal(2), cubePos(3), cubeVal(3));
	if ((edgeTableValue(cubeindex) & 8) !=0)
		vertlist[3] = vertexInterp(isovalue, cubePos(3), cubeVal(3), cubePos(0), cubeVal(0));
	if ((edgeTableValue(cubeindex) & 16) !=0)
		vertlist[4] = vertexInterp(isovalue, cubePos(4), cubeVal(4), cubePos(5), cubeVal(5));
	if ((edgeTableValue(cubeindex) & 32) !=0)
	  	vertlist[5] = vertexInterp(isovalue, cubePos(5), cubeVal(5), cubePos(6), cubeVal(6));
	if ((edgeTableValue(cubeindex) & 64) !=0)
	  	vertlist[6] = vertexInterp(isovalue, cubePos(6), cubeVal(6), cubePos(7), cubeVal(7));
	if ((edgeTableValue(cubeindex) & 128) !=0)
	  	vertlist[7] = vertexInterp(isovalue, cubePos(7), cubeVal(7), cubePos(4), cubeVal(4));
	if ((edgeTableValue(cubeindex) & 256) !=0)
	  	vertlist[8] = vertexInterp(isovalue, cubePos(0), cubeVal(0), cubePos(4), cubeVal(4));
	if ((edgeTableValue(cubeindex) & 512) !=0)
	  	vertlist[9] = vertexInterp(isovalue, cubePos(1), cubeVal(1), cubePos(5), cubeVal(5));
	if ((edgeTableValue(cubeindex) & 1024) !=0)
	  	vertlist[10] = vertexInterp(isovalue, cubePos(2), cubeVal(2), cubePos(6), cubeVal(6));
	if ((edgeTableValue(cubeindex) & 2048) !=0)
	  	vertlist[11] = vertexInterp(isovalue, cubePos(3), cubeVal(3), cubePos(7), cubeVal(7));

	
	// vec4 vert2 = gl_in[0].gl_Position + vec4(0, cubeStep, 0, 0);
	// vec4 vert3 = gl_in[0].gl_Position + vec4(cubeStep, 0, 0, 0);
	// gl_Position = ModelViewProjectionMatrix * gl_in[0].gl_Position;
	// EmitVertex();

	// gl_Position = ModelViewProjectionMatrix * vert2;
	// EmitVertex();

	// gl_Position = ModelViewProjectionMatrix * vert3;
	// EmitVertex();
	// EndPrimitive();
	// Create the triangle
	//FrontColor=vec4(cos(isovalue*10.0-0.5), sin(isovalue*10.0-0.5), cos(1.0-isovalue),1.0);

	int i=0;		
	//for (i=0; triTableValue(cubeindex, i)!=-1; i+=3) { //Strange bug with this way, uncomment to test
	while(true){
	//for(i=0; i<16; i+=3){
		if(triTableValue(cubeindex, i)!=-1){
			//Generate first vertex of triangle//
			//Fill position varying attribute for fragment shader
			position= vec4(vertlist[triTableValue(cubeindex, i)], 1);
			//Fill gl_Position attribute for vertex raster space position
			gl_Position = ModelViewProjectionMatrix* position;
			EmitVertex();
			
			//Generate second vertex of triangle//
			//Fill position varying attribute for fragment shader
			position= vec4(vertlist[triTableValue(cubeindex, i+1)], 1);
			//Fill gl_Position attribute for vertex raster space position
			gl_Position = ModelViewProjectionMatrix* position;
			EmitVertex();

			//Generate last vertex of triangle
			//Fill position varying attribute for fragment shader
			position= vec4(vertlist[triTableValue(cubeindex, i+2)], 1);
			//Fill gl_Position attribute for vertex raster space position
			gl_Position = ModelViewProjectionMatrix* position;
			EmitVertex();
			
			//End triangle strip at firts triangle
			EndPrimitive();
		}else{
			break;
		}
		
		i=i+3; //Comment it for testing the strange bug
	}
}
