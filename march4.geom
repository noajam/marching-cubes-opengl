#version 330 core

layout (points) in;
layout (line_strip, max_vertices=24) out;

// Marching cubes edge lengths
uniform float cubeStep;

uniform vec3 vertexOffsets[8];

uniform mat4 ModelViewMatrix;
uniform mat4 ProjectionMatrix;

void drawEdge(vec3 start, vec3 end, vec4 position, mat4 mvp)
{
    gl_Position = mvp * (vec4(start, 0) + position);
    EmitVertex();
    gl_Position = mvp * (vec4(end, 0) + position);
    EmitVertex();
    EndPrimitive();
}

void main()
{
    // Create MVP Matrix
    mat4 mvp = ProjectionMatrix * ModelViewMatrix;
    vec4 position = gl_in[0].gl_Position;
    
    // // Distance to cube
    // float sphereColoring = step(-1.0, -distance(position.xyz, vec3(0,0,0)));

    // FrontColor = vec4(smoothstep(0.0,1.0,distance(position.xyz, vec3(0,0,0))), smoothstep(1.0,0.0,distance(position.xyz, vec3(0,0,0))), 0, sphereColoring);

    // Bottom edges (0-3)
    drawEdge(vertexOffsets[0], vertexOffsets[1], position, mvp);
    drawEdge(vertexOffsets[1], vertexOffsets[2], position, mvp);
    drawEdge(vertexOffsets[2], vertexOffsets[3], position, mvp);
    drawEdge(vertexOffsets[3], vertexOffsets[0], position, mvp);

    // Top edges (4-7)
    drawEdge(vertexOffsets[4], vertexOffsets[5], position, mvp);
    drawEdge(vertexOffsets[5], vertexOffsets[6], position, mvp);
    drawEdge(vertexOffsets[6], vertexOffsets[7], position, mvp);
    drawEdge(vertexOffsets[7], vertexOffsets[4], position, mvp);

    // Middle edges (8-11)
    drawEdge(vertexOffsets[0], vertexOffsets[4], position, mvp);
    drawEdge(vertexOffsets[1], vertexOffsets[5], position, mvp);
    drawEdge(vertexOffsets[2], vertexOffsets[6], position, mvp);
    drawEdge(vertexOffsets[3], vertexOffsets[7], position, mvp);
}