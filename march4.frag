#version 330 core
// No textures at the moment, but can do a cube map later
uniform float isovalue;

out vec4 FragColor;

void main()
{
    FragColor = vec4(1, 1, 1, 0.15);
}