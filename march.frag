#version 400 core

// No textures

in vec4 color;
out vec4 FragColor;

void main()
{
    FragColor = color;
}