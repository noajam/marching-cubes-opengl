#version 330 core

// No textures at the moment, but can do a cube map later

in vec4 FrontColor;
in vec4 position;
out vec4 FragColor;

uniform float gridSpace;
uniform float isovalue;

void main()
{
    FragColor = vec4(smoothstep(-gridSpace/2, gridSpace/2, position.y), 0, 0, 1);
}